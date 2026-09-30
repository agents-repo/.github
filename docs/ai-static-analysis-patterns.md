# AI contributor guide — recurring SonarQube / ESLint patterns

Coding agents often repeat the same SonarQube Cloud Automatic Analysis and
ESLint (`eslint-plugin-sonarjs`) findings across platform repos. Review this
guide **before** opening pull requests, especially when editing shared scripts
copied between sibling repositories.

This document is guidance only; it does not require fixing historical code in
one sweep.

## When to read this

- Editing `scripts/sync-ide-instructions.mjs`, `scripts/lint-workflows.mjs`,
  `scripts/jscpd-run.mjs`, or other files known to be duplicated per repo.
- Adding or changing regex, YAML/JSON string escaping, or `eslint-disable`
  comments for Sonar rules.
- Preparing a registry pull request that touches `packages/**`.

## Per-repository entry points

| Repository | Always-on agents | Contributor docs |
| --- | --- | --- |
| `.github` | [agents-org.mdc](../.cursor/rules/agents-org.mdc) quick index | [docs/development.md](development.md) (incl. `dup:check` / workspace) |
| `cli` | [agents-cli.mdc](https://github.com/agents-repo/cli/blob/main/.cursor/rules/agents-cli.mdc) § Shared scripts and static analysis | [docs/development.md](https://github.com/agents-repo/cli/blob/main/docs/development.md) § SonarQube Cloud |
| `webapp` | [agents-webapp.mdc](https://github.com/agents-repo/webapp/blob/main/.cursor/rules/agents-webapp.mdc) § Shared scripts and static analysis | [docs/development.md](https://github.com/agents-repo/webapp/blob/main/docs/development.md) § SonarQube Cloud |
| `registry` | [agents-registry.mdc](https://github.com/agents-repo/registry/blob/main/.cursor/rules/agents-registry.mdc) § Shared scripts and static analysis | [docs/ai-onboarding.md](https://github.com/agents-repo/registry/blob/main/docs/ai-onboarding.md); README § SonarQube Cloud and duplication checks |
| `registry-proxy` | [agents-registry-proxy.mdc](https://github.com/agents-repo/registry-proxy/blob/main/.cursor/rules/agents-registry-proxy.mdc) § Shared scripts and static analysis | [docs/AI_GUIDELINES.md](https://github.com/agents-repo/registry-proxy/blob/main/docs/AI_GUIDELINES.md) |

This table is the canonical index for static-analysis and contributor entry
points across platform repos.

## Sonar / ESLint patterns

### 1. Super-linear / catastrophic backtracking (`javascript:S5852`, `sonarjs/super-linear-regex`)

**Avoid** on simple `key: value` lines:

```javascript
const match = /^([\w]+):\s*(.*)$/.exec(line);
// or
const match = /^(\w+):\s*(.*)$/.exec(line);
```

`\s*` before `(.*)$` can trigger backtracking warnings on long lines.

**Prefer** split on the first colon and validate the key:

```javascript
const colonIndex = line.indexOf(':');
if (colonIndex <= 0) continue;
const key = line.slice(0, colonIndex).trim();
if (!/^\w+$/.test(key)) continue;
let value = line.slice(colonIndex + 1).trim();
```

**Checklist:** For `key: value` lines, default to `indexOf` + slice, not
`/^...:\s*(.*)$/`.

### 2. Redundant character classes (`javascript:S6397`)

**Avoid:** `[\w]+` when `\w+` suffices.

**Prefer:** `\w+` or avoid regex (see above).

### 3. Prefer `String.raw` for backslash replacements (`javascript:S7780`)

**Avoid:**

```javascript
rule.description.replaceAll('"', '\\"');
```

**Prefer:**

```javascript
rule.description.replaceAll('"', String.raw`\"`);
```

**Checklist:** Any `replace` / `replaceAll` whose replacement contains `\`
should use `String.raw` or a `RegExp` with clear intent.

### 4. When `eslint-disable-next-line sonarjs/...` is acceptable

- Prefer refactoring when the fix is mechanical (see patterns above).
- Disable only for a **single line**, with a short comment explaining why
  refactor is unsafe or misleading (for example platform-specific branches in
  `lint-workflows.mjs`).
- Do not blanket-disable Sonar rules on whole files without maintainer agreement.

### 5. Trusted `PATH` for subprocesses (`javascript:S4036`)

Sonar flags `spawnSync('npx', …)`, `execSync('tool', …)`, and similar calls when
the executable name is resolved through the caller’s `PATH`, which may include
user-writable directories.

**Avoid:**

```javascript
spawnSync('npx', ['jscpd', '--config', config, target], { cwd: REPO_ROOT });
```

**Prefer** an absolute CLI under `node_modules` plus the current Node binary:

```javascript
const jscpdCli = path.join(REPO_ROOT, 'node_modules', 'jscpd', 'bin', 'jscpd');
spawnSync(process.execPath, [jscpdCli, '--config', config, target], {
  cwd: REPO_ROOT,
  stdio: 'inherit',
});
```

For OS utilities (`curl`, `tar`, `actionlint` on `PATH`), reuse the trusted
`PATH` pattern in `scripts/lint-workflows.mjs` (`TRUSTED_PATH_DIRS` +
`resolveTrustedExecutable` / `trustedEnv()`). Do not append `node_modules/.bin`
to `PATH` to satisfy Sonar; resolve the binary path instead.

**Checklist:** Hub workspace scripts that spawn tools should mirror
`lint-workflows.mjs` or `jscpd-run.mjs`, not bare `npx` / unqualified command
names. `package.json` `dup:check` scripts may keep `jscpd` because npm prepends
`node_modules/.bin` only for that npm lifecycle invocation.

## Duplicated fixes across sibling repos

`scripts/sync-ide-instructions.mjs` is **copied** in the org hub (`.github`),
`cli`, `webapp`, `registry`, and `registry-proxy`. A fix in one copy usually
belongs in **all** copies unless an intentional fork is documented.

**Checklist:** After editing one copy, search sibling clones for the same
pattern before handoff:

```bash
# From org hub clone, example:
rg -l 'parseSimpleYaml' ../cli ../webapp ../registry ../registry-proxy .
```

## SonarQube Cloud

Organization norms live in [CONTRIBUTING.md — SonarCloud Automatic Analysis](../CONTRIBUTING.md#sonarcloud-automatic-analysis).

- Automatic Analysis reads **`.sonarcloud.properties`** per repository (not
  `sonar-project.properties`).
- `sonar.sources` and `sonar.tests` must be **disjoint** directory lists.
- Application repos with nested tests set explicit source/test roots; see each
  repo’s `.sonarcloud.properties` and `docs/development.md`.
- **Registry** also runs local ESLint with Sonar rules: `npm run lint:sonar`.

PR path-filtered baselines are summarized in [docs/ci.md](ci.md).

## Registry-only: package PR title vs `package:validate`

When a registry PR touches `packages/**`, CI requires the PR title to start with
`feat(package):` or `fix(package):` even if the branch is `chore/...`.

Rename the PR title (squash title) to e.g. `fix(package): …` while keeping
chore context in the PR body.

## Local duplication checks (jscpd)

[jscpd](https://github.com/kucherenko/jscpd) finds copy-paste duplication.
**It is not run in GitHub Actions yet** (see [Future CI](#future-ci)).

| Command | Where | Purpose |
| --- | --- | --- |
| `npm run dup:check` | Any repo with jscpd configured | Scan **this repository** only |
| `npm run dup:check:workspace` | Org `.github` hub | Scan hub + sibling `cli`, `webapp`, `registry`, `registry-proxy` when clones exist |
| `npm run dup:check:cross-workspace` | Org `.github` hub (optional) | Also include `feline-click` siblings when checked out next to `agents-repo` |

**When to run:** Before handoff when you change shared scripts or copy logic
between repos. Record a short summary in the draft PR validation section.

First runs may report many clones (known copies such as `sync-ide-instructions.mjs`);
use reports to decide whether to fix, exclude paths in `.jscpd.json`, or track
deduplication work separately.

## Future CI

After baselines and thresholds are agreed, implement blocking checks per
repository. Tracking issue: [agents-repo/.github#126](https://github.com/agents-repo/.github/issues/126).

Prerequisites before enabling CI:

1. Shared `.jscpd.json` ignores (generated mirrors, `node_modules`, build output).
2. Documented `minLines` / `minTokens` from a maintainer baseline run.
3. No wiring into `lint:all` until the CI issue is implemented.
