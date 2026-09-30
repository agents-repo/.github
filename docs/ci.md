# Continuous integration

The **agents-repo** organization uses a **multi-repo layout**: each platform
repository owns its merge gate on `main`. The org repository
([agents-repo/.github](https://github.com/agents-repo/.github)) holds shared
governance, git workspace scripts, and the **org hub** registry workflow catalog
—it does not build the webapp, CLI, or registry-proxy Worker.

See [org-workspace-and-agents.md](org-workspace-and-agents.md) for where
registry skills install and how to open the multi-root workspace.

## Where CI runs

| Repository | Workflow | Triggers | Always-on baseline | Path-filtered extras |
| --- | --- | --- | --- | --- |
| [.github](https://github.com/agents-repo/.github) | [pr-baseline.yml](../.github/workflows/pr-baseline.yml) | `pull_request` | Workflow lint, ShellCheck on git scripts, IDE sync check | Chrome + `slides:check`, **`agents:verify`** |
| [cli](https://github.com/agents-repo/cli) | [pr-baseline.yml](https://github.com/agents-repo/cli/blob/main/.github/workflows/pr-baseline.yml) | `pull_request` | `env:check`, `lint:all`, IDE sync, typecheck, tests, `check:secrets` | Chrome + `slides:check`; optional `compat-node22` — **no `agents:verify`** |
| [webapp](https://github.com/agents-repo/webapp) | [pr-baseline.yml](https://github.com/agents-repo/webapp/blob/main/.github/workflows/pr-baseline.yml) | `pull_request` | `env:check`, `lint:all`, IDE sync, typecheck, tests | Chrome + `slides:check`, `build:pages` + crawl tests, CLI `check:docs-sync` — **no `agents:verify`** |
| [registry](https://github.com/agents-repo/registry) | [pr-baseline.yml](https://github.com/agents-repo/registry/blob/main/.github/workflows/pr-baseline.yml) | `pull_request` | `env:check`, `lint:all`, IDE sync, tests, typecheck | Chrome + `slides:check`, **`agents:verify`** (minimal package-creation catalog), `package:scan-zips` |
| [registry-proxy](https://github.com/agents-repo/registry-proxy) | [pr-baseline.yml](https://github.com/agents-repo/registry-proxy/blob/main/.github/workflows/pr-baseline.yml) | `pull_request` | `env:check`, `lint:all`, IDE sync, tests, `check:secrets` | Chrome + `slides:check` — **no `agents:verify`** |

Each repository may also run release, deploy, or `main`-branch safety-net jobs
not listed here. See that repo’s `.github/workflows/` and
`.github/CONTRIBUTING.md`.

## Which checks must pass for your PR

Open the pull request on the **repository that owns the changed files**:

- **cli** changes → `agents-repo/cli` PR baseline must pass.
- **webapp** changes → `agents-repo/webapp` PR baseline (and deploy safety nets
  when applicable).
- **registry** package or spec work → `agents-repo/registry`.
- **registry-proxy** Worker changes → `agents-repo/registry-proxy`.
- Org templates, hub catalog, git scripts, or org docs → **`agents-repo/.github`**.

Cross-repo work (for example CLI command docs mirrored on the site) may need
**multiple PRs** in sibling repos with linked issues.

## `agents:verify` in CI

Only these clones commit an `agents.json` catalog and run **`agents:verify`** in
PR baseline when agents definition paths change:

| Repository | Catalog role |
| --- | --- |
| **`.github`** | Full org hub: shared `maiconfz/*` planning and review packages (all install targets). |
| **`registry`** | Minimal catalog: `agents-repo/agents-repo-package-creation` only. |

**cli**, **webapp**, and **registry-proxy** do **not** run `agents:verify` in
CI. Contributors use the org hub catalog and
[agents-repo.code-workspace](../agents-repo.code-workspace) for Cursor skills.

Path triggers and lockfile exceptions are defined in
[CONTRIBUTING — Lockfiles vs agents verify](../CONTRIBUTING.md#lockfiles-vs-agents-verify-exception).

## Local parity (before opening a PR)

| Repository | Typical handoff |
| --- | --- |
| `.github` | `npm ci && npm run lint:all && npm run sync:ide-instructions -- --check`; `agents:verify` / `agents:ci` when catalog paths change |
| cli | `npm ci && npm run lint:all && npm test` |
| webapp | `npm ci && npm run lint:all && npm run test && npm run typecheck` |
| registry | `npm ci && npm run lint:all && npm test`; `agents:verify` when catalog paths change |
| registry-proxy | `npm ci && npm run lint:all && npm test` |

When you change duplicated `scripts/` (for example `sync-ide-instructions.mjs`),
run `npm run dup:check` in the touched repository before handoff. From the org
hub clone, also run `npm run dup:check:workspace` when sibling platform repos
are checked out. See [Local duplication checks (jscpd)](ai-static-analysis-patterns.md#local-duplication-checks-jscpd).
jscpd is **not** part of PR baseline CI until
[agents-repo/.github#126](https://github.com/agents-repo/.github/issues/126).

## Contributor guides

- Org hub and workspace: [org-workspace-and-agents.md](org-workspace-and-agents.md)
- Local git scripts: [local-git-workspace.md](local-git-workspace.md)
- Cursor Cloud: [cursor-cloud.md](cursor-cloud.md)
- Per-repo static-analysis and contributor entry points: [ai-static-analysis-patterns.md — Per-repository entry points](ai-static-analysis-patterns.md#per-repository-entry-points) (canonical table); each repo’s `.github/CONTRIBUTING.md` for workflow norms
