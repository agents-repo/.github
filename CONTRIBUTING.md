# Contributing

Thanks for contributing to the agents-repo ecosystem.

By contributing to this organization, you agree that your contributions are licensed under the [MIT License](LICENSE) unless a repository specifies a different license.

## Code of Conduct

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold it.

## Security

Please report vulnerabilities privately with GitHub Private Vulnerability
Reporting instead of public GitHub issues, discussions, pull requests, or
public social channels (including X and Reddit). See [SECURITY.md](SECURITY.md)
for private reporting instructions.

## Where to contribute

Choose the repository that matches the kind of work you want to do, then follow that repository's detailed contributing guide.

| Repository | Purpose | Detailed guide |
| --- | --- | --- |
| [registry](https://github.com/agents-repo/registry) | Specs, schemas, packages | [`.github/CONTRIBUTING.md`](https://github.com/agents-repo/registry/blob/main/.github/CONTRIBUTING.md) |
| [webapp](https://github.com/agents-repo/webapp) | Registry UI | [`.github/CONTRIBUTING.md`](https://github.com/agents-repo/webapp/blob/main/.github/CONTRIBUTING.md) |
| [registry-proxy](https://github.com/agents-repo/registry-proxy) | Cloudflare Worker proxy | [`.github/CONTRIBUTING.md`](https://github.com/agents-repo/registry-proxy/blob/main/.github/CONTRIBUTING.md) |
| [cli](https://github.com/agents-repo/cli) | Official `npx agents-repo` CLI | [`.github/CONTRIBUTING.md`](https://github.com/agents-repo/cli/blob/main/.github/CONTRIBUTING.md) |
| [.github](https://github.com/agents-repo/.github) | Organization-wide defaults | This repository — open an issue before implementation here |
| [agents-repo.github.io](https://github.com/agents-repo/agents-repo.github.io) | Automated Pages deploy target for webapp (not a development repo) | See [webapp deployment docs](https://github.com/agents-repo/webapp/blob/main/docs/deployment.md) |

## Docs and repository pages

For user guides and cross-repo documentation, see
[agents-repo.org/docs/](https://agents-repo.org/docs/).
For this repository's overview on the public site, see
[agents-repo.org/repositories/github/](https://agents-repo.org/repositories/github/).

When you change a user-facing or contributor workflow in this
repository, update the corresponding page(s) in
[agents-repo/webapp](https://github.com/agents-repo/webapp) under
`src/content/docs/` in the same PR or an immediate follow-up.

## Local multi-repo workspace

If you keep organization repositories as sibling directories under one parent
folder, use the shell scripts documented in
[docs/local-git-workspace.md](docs/local-git-workspace.md) (`scripts/git-*.sh`)
to fetch, prune stale locals, and refresh the default branch across clones.

## Required Workflow

Every task in an active development repository MUST follow this full lifecycle.

### Task setup (before implementation)

1. **Issue first** — Open a tracking issue (matching issue form when available)
   before any implementation work.
2. **Branch second** — Create a non-`main` branch named
   `<prefix>/<issue-number>-<slug>` from the latest `main`.
3. **Push and draft PR third** — Push the branch (including an empty scaffold
   commit if needed so head differs from `main`), then open a **draft** pull
   request targeting `main` before substantive implementation commits. Pull
   requests MUST be created as drafts (`gh pr create --draft` or the GitHub UI
   draft option). Do not open a non-draft pull request at creation time. In
   `## Related Issues`, include `Closes #<issue-number>` for standard tasks,
   or follow **Workflow exceptions** for security-advisory references. GitHub
   cannot open a pull request when the head and base branches are identical;
   an empty commit is sufficient when no file changes are needed yet (for
   example
   `git commit --allow-empty -m "chore: scaffold draft PR for #<issue-number>"`).
   Implementation commits may follow on the same branch.

### Delivery (after draft PR)

1. **Implement and validate** — Push implementation commits to the task branch
   and run the target repository's validation commands.
2. **Ready for review** — After validation passes, the developer manually
   marks the pull request ready for review in GitHub. Agents and automation
   MUST NOT mark pull requests ready for review.
3. **PR-only `main`** — All integration to `main` MUST happen via merged pull
   request. Direct commits or pushes to `main` MUST NOT be used (humans and
   agents).
4. **Agent handoff** — Agents complete requested implementation work on the
   task branch, then hand off. Human developers mark pull requests ready for
   review after validation; maintainers merge. Agents MUST NOT mark pull
   requests ready for review or merge to `main`.

### Pre-ready agent handoff

While the pull request remains a **draft**, agents MUST complete the following
before handoff (humans still mark the PR ready for review):

1. When using issue planning, follow the refined plan; do not expand scope
   without user or issue clarification.
2. Before editing, read **exemplar** code or documentation in the same area of
   the target repository.
3. Run the target repository's validation commands (see that repository's
   `CONTRIBUTING` and agent instructions); record command output or a summary
   in the draft pull request and agent handoff.
4. Perform a **self-review**: correctness, edge cases, error/empty/loading
   behavior, accessibility for UI changes, and alignment with specs and docs.
5. Update the **draft** pull request description with validation evidence,
   risks, and explicit out-of-scope items.
6. Agents and automation **MUST NOT** mark pull requests ready for review.
7. After a human marks the pull request ready, GitHub Copilot or other
   reviewers may comment. Use the `github-pr-review-triage` workflow where
   available for follow-up—**not** as a substitute for these pre-ready steps.

Repository-specific validation commands and optional IDE tooling are documented
in each repository's contributor and agent instruction files.

## Workflow exceptions

1. **Security vulnerabilities** — Follow [SECURITY.md](SECURITY.md).
   Maintainers deliver the fix using the private advisory flow rather than a
   public tracking issue. Branch and draft pull request are still required
   before merge to `main`. In `## Related Issues`, use `Closes #<issue-number>`
   when maintainers provide a linked private or advisory tracking issue.
   Otherwise, reference the private security advisory identifier (for example
   `GHSA-...`) in `## Related Issues` and coordinate linkage with maintainers.
2. **Maintainer emergency hotfix** — Work on a `fix/<issue-number>-<slug>`
   branch (for example `fix/42-hotfix-cache-regression`) only with prior
   maintainer approval documented in an issue or advisory. Do not use a
   separate `hotfix/` prefix. Delivery to `main` is still via merged pull
   request (no direct push).
3. **Organization `.github` repository** — Plain issues are acceptable (no issue
   forms). Issue, branch, and draft pull request are still required.
4. **Registry package submissions** — Contributors to **agents-repo/registry**
   MAY omit a tracking issue for package submissions and corrections; an issue
   remains recommended. External contributors SHOULD fork the registry and open
   a pull request from the fork to upstream `main`. When a tracking issue
   exists, branch `package/<issue-number>-<slug>` and include
   `Closes #<issue-number>` in `## Related Issues`. Without an issue, branch
   `package/<slug>` and describe the package in `## Related Issues`. This
   exception does **not** relax issue-first requirements for webapp, cli,
   registry-proxy, or non-package registry work (specs, tooling, platform
   changes). The suggested authoring path after the draft pull request is the
   in-tree `full-package-creation-flow`; see [Submit a
   package](https://agents-repo.org/docs/submitting-a-package).

## Marketing and install-target vocabulary

Platform repos SHOULD follow the organization
[marketing and install-target vocabulary](https://github.com/agents-repo/.github/blob/main/docs/marketing-vocabulary.md)
for tool-agnostic product voice, install target display names, and SEO/npm
keyword guidance. Normative install target IDs remain in the
[install-targets spec](https://github.com/agents-repo/registry/blob/main/specs/install-targets.md).

## Shared norms

These norms apply across the organization unless a repository guide specifies
otherwise.

1. Follow the Required Workflow above for every implementation task.
2. Create branches from the latest default branch using
   `<prefix>/<issue-number>-<slug>`, where `<slug>` is short lowercase
   kebab-case. See **Branch prefix reference** below.
3. Prefer the [`gh` CLI](https://cli.github.com/) for issue and pull request
   communication.
4. Issue forms capture intent only; use the number GitHub assigns after
   submission when naming branches and writing PR `## Related Issues`—do not
   edit issue bodies to add the number.
5. Use conventional commit prefixes such as `feat`, `fix`, `docs`, `chore`,
   `refactor`, `perf`, `test`, `build`, `ci`, and `revert`.
6. Keep pull requests focused and include validation evidence required by the
   target repository.
7. All contributors MUST integrate changes to the default branch only through
   merged pull requests. AI agents MUST NOT merge pull requests into the
   default branch or push commits directly to it. Integration to the default
   branch is a human-only step after review.

When this document conflicts with a repository's own `CONTRIBUTING.md`, the repository guide takes precedence.

### Branch prefix reference

| Work type | Issue form (when available) | Branch prefix | Example |
| --- | --- | --- | --- |
| Bug or inconsistency | `bug-inconsistency.yml` | `fix/` | `fix/42-proxy-cache-mismatch` |
| Spec change | `spec-change.yml` | `spec/` | `spec/7-add-contract-schema` |
| Feature proposal | `feature-proposal.yml` | `feat/` | `feat/8-install-package` |
| Task or chore | `task-chore.yml` | `chore/` | `chore/31-sync-workflow-docs` |
| Documentation-only (non-spec) | `task-chore.yml` | `docs/` | `docs/88-update-pr-guidance` |
| Registry package (exception) | package forms or none | `package/` | `package/my-package` or `package/56-my-package` |

Notes:

1. Repository `CONTRIBUTING.md` takes precedence for repo-specific rules.
2. `spec-change.yml` and `spec/` are **not used in registry-proxy** (no
   normative `specs/` tree).
3. This organization `.github` repository uses plain issues; branch prefixes
   still apply.
4. Branch prefix categorizes work; **commit** (or squash-merge) prefix determines
   automated release bumps—not the branch name.
5. Issue title prefixes (`spec:`, `chore:`, etc.) are for GitHub only. Use
   `feat:`, `fix:`, `docs:`, or `chore:` on squash-merge unless registry
   package PR title rules apply (`feat(package):` / `fix(package):`).
6. Emergency hotfix: use `fix/<issue-number>-<slug>` with maintainer approval (no
   separate `hotfix/` prefix). See **Workflow exceptions** above.

## GitHub Actions workflow linting

Repositories that contain `.github/workflows/` **MUST** validate workflow files with
[actionlint](https://github.com/rhysd/actionlint). YAML parse checks (for example
`js-yaml` in `scripts/lint-yaml.js`) do **not** catch invalid GitHub Actions
expression contexts (such as `secrets` in a step `if`), which GitHub rejects at
parse time.

### Norm

1. Provide `npm run lint:workflows` that runs actionlint on all files under
   `.github/workflows/`.
2. Include `lint:workflows` in `npm run lint:all` so PR baseline CI (which runs
   `lint:all` where configured) enforces workflow semantics.
3. Pin the actionlint **release version** in `scripts/lint-workflows.mjs` (single
   constant). Vendor the matching
   `scripts/actionlint_<version>_checksums.txt` from the GitHub release (same
   basename as upstream). Use the **same version** and checksums file across
   organization repositories unless a security bump is coordinated. Current pin:
   **1.7.12**.
4. Document local expectations in that repository’s contributor docs (install from
   [releases](https://github.com/rhysd/actionlint/releases), Homebrew, or rely on
   the repository bootstrap script).

Repositories **MAY** keep `scripts/lint-yaml.js` (or equivalent) for
`.github/actions/` and `.github/ISSUE_TEMPLATE/`; actionlint does not replace that
in v1.

Repositories **MUST NOT** use `secrets` or other restricted contexts in job or step
`if` expressions; validate presence via `env` and shell instead.

### Recommended implementation pattern

- Add `scripts/lint-workflows.mjs` that runs the pinned binary from
  `.cache/actionlint/` (gitignored), downloading from GitHub releases with a
  cross-process lock when missing, and falling back to `PATH` only when bootstrap
  fails but a matching `actionlint` is installed.
- In GitHub Actions, restore `.cache/actionlint/` with `actions/cache` keyed on
  runner OS/arch and the vendored checksums plus `scripts/lint-workflows.mjs`.
- When `gh` and `GITHUB_TOKEN`/`GH_TOKEN` are available (GitHub-hosted runners),
  download the release archive with `gh release download` first. Fall back to
  curl against the public GitHub Releases URL. Public CDN 503s are common; the
  GitHub API path used by `gh` is the reliable CI source.
- Commit `scripts/actionlint_<pinned-version>_checksums.txt` from the matching
  GitHub release. The bootstrap script uses that file for SHA-256 verification
  and only downloads checksums when the vendored file is missing. Do not commit
  `.cache/actionlint/`.
- Add `"lint:workflows": "node scripts/lint-workflows.mjs"` and chain into
  `lint:all`.
- Optional `.actionlint.yaml` for documented ignore rules when actionlint reports
  false positives.

### Local setup

Before pushing changes under `.github/workflows/`, run:

```bash
npm run lint:workflows
```

(or `npm run lint:all` where that includes workflow lint).

### Actionlint version bumps

When raising the pinned actionlint version, do this in **every** organization
repository that vendors `scripts/lint-workflows.mjs` (currently `.github`,
`webapp`, `registry`, `registry-proxy`, and `cli`), using the same version
unless a security bump is coordinated:

1. Update `ACTIONLINT_VERSION` in `scripts/lint-workflows.mjs`.
2. Download `actionlint_<new-version>_checksums.txt` from the matching
   [actionlint GitHub release](https://github.com/rhysd/actionlint/releases)
   and commit it as `scripts/actionlint_<new-version>_checksums.txt`.
3. Remove `scripts/actionlint_<old-version>_checksums.txt`.
4. Update the **Current pin** line in this section.
5. Run `npm run lint:workflows`.

CI cache keys that hash `scripts/actionlint_*_checksums.txt` and
`scripts/lint-workflows.mjs` invalidate automatically on this bump. Do not
hardcode the actionlint version in `actions/cache` keys.

The checksums file is source, not a cache artifact. Keep it committed so
bootstrap checksum verification does not depend on GitHub being reachable for
that file.

### Adoption tracking

Per-repository enforcement:

- [agents-repo/webapp#128](https://github.com/agents-repo/webapp/issues/128)
- [agents-repo/registry#103](https://github.com/agents-repo/registry/issues/103)
- [agents-repo/registry-proxy#38](https://github.com/agents-repo/registry-proxy/issues/38)
- [agents-repo/cli#53](https://github.com/agents-repo/cli/issues/53)

## Agent instruction files

| Repository | GitHub Copilot | Cursor | Claude Code | OpenAI Codex |
| --- | --- | --- | --- | --- |
| [registry](https://github.com/agents-repo/registry) | `.github/copilot-instructions.md` | `.cursor/rules/agents-registry.mdc` | `CLAUDE.md` | `AGENTS.md` |
| [webapp](https://github.com/agents-repo/webapp) | `.github/copilot-instructions.md` | `.cursor/rules/agents-webapp.mdc` | `CLAUDE.md` | `AGENTS.md` |
| [registry-proxy](https://github.com/agents-repo/registry-proxy) | `.github/copilot-instructions.md` | `.cursor/rules/agents-registry-proxy.mdc` | `CLAUDE.md` | `AGENTS.md` |
| [cli](https://github.com/agents-repo/cli) | `.github/copilot-instructions.md` | `.cursor/rules/agents-cli.mdc` | `CLAUDE.md` | `AGENTS.md` |
| [.github](https://github.com/agents-repo/.github) (this repo) | `.github/copilot-instructions.md` | `.cursor/rules/agents-org.mdc` | `CLAUDE.md` | `AGENTS.md` |

In each child repository (including `cli`), run `npm run sync:ide-instructions`
in that repo after editing its `.github/copilot-instructions.md`. Older
documentation may refer to the retired `sync:cursor-rules` npm script name.

Edit `.github/copilot-instructions.md` as the canonical project-guidelines source.
Regenerate IDE mirrors after changes:

```bash
npm run sync:ide-instructions
```

Do not edit `.cursor/rules/`, `CLAUDE.md`, or `AGENTS.md` directly when they are
generated mirrors.

This repository uses automated sync for Cursor, Claude Code, and OpenAI Codex
mirrors — replacing the former manual Pattern B (edit Copilot and Cursor files
in the same change).

### Registry workflow packages (CLI)

Install and refresh catalog packages with the [agents-repo CLI](https://github.com/agents-repo/cli).
`agents.json` points at `https://registry-proxy.maiconfz.workers.dev` (organization
catalog proxy).

Bootstrap only when `agents.json` is missing (one-time; use a published CLI
release or `npm exec agents-repo -- init` after `npm ci`):

```bash
npm exec agents-repo -- init --targets github-copilot claude-code cursor openai-codex
```

Use the npm scripts for bulk install, update, and CI (CLI version is pinned in
`package.json` / `package-lock.json`, distinct from registry packages in
`agents-lock.json`):

```bash
npm run agents:install   # bulk sync from agents.json
npm run agents:update    # refresh within semver ranges
npm run agents:ci        # same command pr-baseline uses after npm ci
```

Commit `agents.json`, `agents-lock.json`, and extracted paths (`.github/agents/`,
`.cursor/skills/`, `.claude/agents/`, `.agents/skills/`). Do not hand-edit
extracted package files.

## Changing organization-wide defaults

To update community health files, templates, or other shared configuration for
the organization, open an issue before implementation in
[agents-repo/.github](https://github.com/agents-repo/.github).

For help choosing the right repository or channel, see [SUPPORT.md](SUPPORT.md).

## Maintainer enforcement

Documentation alone cannot prevent direct pushes to `main`. Maintainers SHOULD
enforce the PR-only policy on `main` with GitHub branch protection or
repository rulesets for these active development repositories:

- `agents-repo/.github`
- `agents-repo/registry`
- `agents-repo/webapp`
- `agents-repo/registry-proxy`
- `agents-repo/cli`

Release automation on `agents-repo/cli` pushes version commits via a dedicated
GitHub App listed on the repository ruleset bypass list; see
[protected `main` release setup for `agents-repo/cli`](https://github.com/agents-repo/cli/blob/main/docs/npm-publishing.md#protected-main-and-release-automation).

Recommended settings (via branch protection or rulesets):

1. **Require a pull request before merging** — all integration to `main` goes
   through review and merge.
2. **Block direct pushes to `main`** — enforce the PR-only policy at the
   platform level.
3. **Require status checks to pass** — enable required CI workflows where
   available (for example PR baseline, lint, test, and typecheck jobs).

`agents-repo.github.io` is excluded; it is an automated deployment target for
the webapp, not a development repository.

Configuring branch protection or rulesets is a maintainer action in GitHub
repository settings and is not applied by changes in this repository.
