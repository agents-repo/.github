<!-- Generated: .cursor/rules/agents-org.mdc. Run npm run sync:ide-instructions -->

# Organization .github Repository — Agent Guidelines

## Quick index

| Topic | Where to start |
| --- | --- |
| Org hub catalog and workspace | [docs/org-workspace-and-agents.md](../docs/org-workspace-and-agents.md) |
| CI by repository | [docs/ci.md](../docs/ci.md) |
| Sonar / ESLint patterns + local jscpd | [docs/ai-static-analysis-patterns.md](../docs/ai-static-analysis-patterns.md) |
| Required workflow (issue → branch → draft PR) | [CONTRIBUTING.md — Required Workflow](../CONTRIBUTING.md#required-workflow) |
| Local sibling clones + git scripts | [docs/local-git-workspace.md](../docs/local-git-workspace.md) |
| Multi-root workspace file | [agents-repo.code-workspace](../agents-repo.code-workspace) |
| Child repo agent entry | [cli](https://github.com/agents-repo/cli), [webapp](https://github.com/agents-repo/webapp), [registry](https://github.com/agents-repo/registry), [registry-proxy](https://github.com/agents-repo/registry-proxy) — each repo's `AGENTS.md` |
| Hub registry packages | [CONTRIBUTING — Registry workflow packages](../CONTRIBUTING.md#registry-workflow-packages-org-hub) + [section below](#registry-workflow-agents) |

## Project Purpose

This repository holds organization-wide community health files, the **org hub**
registry workflow catalog, shared git workspace scripts, and governance for the
**agents-repo** GitHub organization.

Repository-level files in other repos override these defaults when GitHub
applies community health file inheritance.

Human contributor guidance lives at the repository root:

- [CONTRIBUTING.md](../CONTRIBUTING.md)
- [docs/development.md](../docs/development.md)
- [SECURITY.md](../SECURITY.md)
- [SUPPORT.md](../SUPPORT.md)

## Child Repositories

| Repository | Agent instructions |
| --- | --- |
| [registry](https://github.com/agents-repo/registry) | `.cursor/rules/agents-registry.mdc` → synced mirrors |
| [webapp](https://github.com/agents-repo/webapp) | `.cursor/rules/agents-webapp.mdc` → synced mirrors |
| [registry-proxy](https://github.com/agents-repo/registry-proxy) | `.cursor/rules/agents-registry-proxy.mdc` → synced mirrors |
| [cli](https://github.com/agents-repo/cli) | `.cursor/rules/agents-cli.mdc` → synced mirrors |
| [.github](https://github.com/agents-repo/.github) (this repo) | `.cursor/rules/agents-org.mdc` → synced mirrors |

This repository does not use issue forms. Open a plain issue before
implementation for organization-wide documentation and configuration changes.

## Cursor configuration

| Path | Purpose |
| --- | --- |
| [`.cursor/rules/`](../.cursor/rules/agents-org.mdc) | Always-on org rules (`agents-org.mdc`) |
| [`.cursor/skills/`](../.cursor/skills) | Registry workflow packages (org hub install target) |
| [agents-repo.code-workspace](../agents-repo.code-workspace) | Multi-root workspace including sibling platform repos |

Child repos keep repo-specific `.cursor/rules/` for coding standards. Shared
planning/review skills install **here**, not in cli/webapp/registry-proxy.

## Registry workflow agents

Curated packages from [registry.agents-repo.org](https://registry.agents-repo.org)
install **only** in this repository (`agents.json`, `agents-lock.json`,
`.cursor/skills/`). Open the workspace file so Cursor loads these skills while
editing sibling clones.

| Package | Primary entry |
| --- | --- |
| `maiconfz/feature-exploration-planner` | `feature-exploration-planning` flow |
| `maiconfz/github-interactive-issue-implementation-planner` | `issue-implementation-planning` flow |
| `maiconfz/plan-refiner` | Plan refinement skills |
| `maiconfz/review-fix-ship` | `review-fix-ship` flow (local diff review) |
| `maiconfz/github-pr-review-triage` | PR review triage (after push) |
| `maiconfz/ai-first-project-readiness` | AI readiness planning |
| `maiconfz/context-token-reduction` | Context token reduction |

**Issues:** Open tracking issues on the **repository that owns the work** (webapp,
cli, registry, etc.). Org-wide changes use **this** repository. Do not default
gh-backed flows to `agents-repo/.github` unless the issue lives here.

**Do not edit** extracted files under `.cursor/skills/`. Fix upstream in
[registry](https://github.com/agents-repo/registry), publish, bump `agents.json`
here, then `npm run agents:install` / `agents:verify` / `agents:ci`.

CLI maintenance: [docs/org-workspace-and-agents.md](../docs/org-workspace-and-agents.md#cli-contributors-verifying-the-hub-lock).

## Required Workflow (Task Start)

Follow [CONTRIBUTING.md — Required Workflow](../CONTRIBUTING.md#required-workflow)
(plain issue in this repository → `chore/<issue>-<slug>` branch → draft PR
before implementation). Use [branch prefix reference](../CONTRIBUTING.md#branch-prefix-reference)
for prefixes. Agents MUST NOT push to `main`, merge PRs into `main`, or mark
pull requests ready for review.

## Pre-ready agent handoff

Follow [CONTRIBUTING.md — Pre-ready agent handoff](../CONTRIBUTING.md#pre-ready-agent-handoff).
Record validation evidence in the draft PR.

## Default Branch Integration (Agents)

Agents MUST NOT merge or push to `main`. Integration is human-only after review.

## GitHub Communication (gh CLI)

Prefer `gh` for issues and draft PRs (`gh pr create --draft`). See
[CONTRIBUTING.md — Shared norms](../CONTRIBUTING.md#shared-norms).

## Cursor Cloud environment

Multi-repo workspace is intentional: `repositoryDependencies` loads sibling
repos so contributors see org and child-repo norms in one session. See
[docs/cursor-cloud.md](../docs/cursor-cloud.md) for install, pinned Node/npm,
`.cursorignore` template, and path-scoped Copilot instructions.

Do not start long-running servers from `install`.

## Validation

Before handing off work on this repository, run:

```bash
npm run lint:all
npm run sync:ide-instructions -- --check
```

When the change touches slide sources, also run `npm run slides:check` (see
[docs/slides/README.md](../docs/slides/README.md)). When the change touches
`agents.json`, `agents-lock.json`, or extracted agent/skill paths, also run
`npm run agents:verify` (PR baseline parity). Run full `npm run agents:ci`
locally before changing registry locks or extracted package files.

Optional: `npm run env:check` verifies pinned Node/npm when present.

PR baseline extras (Chrome/`slides:check` and `agents:verify`) are path-filtered.
See [CONTRIBUTING.md — PR baseline extras (path filters)](../CONTRIBUTING.md#pr-baseline-extras-path-filters).
Do not treat npm lockfiles as an `agents:verify` trigger.

## IDE Instructions in This Repository

Edit `.cursor/rules/agents-org.mdc` (this file) as the canonical source, then
regenerate mirrors:

```bash
npm run sync:ide-instructions
```

Mirrors: `.github/copilot-instructions.md`, `CLAUDE.md`, `AGENTS.md`. Do not edit
generated mirror files directly.
