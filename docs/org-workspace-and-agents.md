# Organization workspace and registry workflow agents

This document describes how **agents-repo** contributors share registry workflow
packages (planning, review, triage skills) without duplicating `agents.json` in
every platform repository.

## Where the catalog lives

| Clone | `agents.json` | Purpose |
| --- | --- | --- |
| **[agents-repo/.github](https://github.com/agents-repo/.github)** | Full curated set (`maiconfz/*` planning and review packages) | **Org hub** — install targets: Copilot, Claude Code, Cursor, OpenAI Codex |
| **[agents-repo/registry](https://github.com/agents-repo/registry)** | `agents-repo/agents-repo-package-creation` only | In-tree package authoring flows |
| **cli**, **webapp**, **registry-proxy** | None at repo root | Use hub + workspace for skills; keep repo-specific CI and coding rules |

Do **not** hand-edit files under `.cursor/skills/`, `.github/agents/`, or other
extract paths in the hub or registry. Change upstream packages in
[registry](https://github.com/agents-repo/registry), publish, then bump semver in
the hub (or registry) and run `npm run agents:install` / `agents:verify` /
`agents:ci` as documented in [CONTRIBUTING — Registry workflow packages](../CONTRIBUTING.md#registry-workflow-packages-org-hub).

## Sibling clone layout

```text
~/dev/projects/agents-repo/     ← workspace root (WORKSPACE_ROOT)
  .github/                      ← org hub (agents.json, git scripts, workspace file)
  cli/
  registry/
  registry-proxy/
  webapp/
  agents-repo.github.io/        ← optional
```

Git maintenance scripts live under **`.github/scripts/`** — see
[local-git-workspace.md](local-git-workspace.md).

## Multi-root Cursor / VS Code workspace

Open **[agents-repo.code-workspace](../agents-repo.code-workspace)** from the
**`.github` clone** (**File → Open Workspace from File**).

The workspace loads the org hub folder first so **`.cursor/skills/`** from
**`.github`** is available while you edit code in cli, webapp, registry, or
registry-proxy.

Opening a **single** child repo alone does **not** load org registry skills.
Use the workspace file for planning and review flows.

## Typical registry workflow order

Invoke skills or flows by name in Cursor (packages installed in the hub):

1. `feature-exploration-planning` — landscape and options (upstream of issue planning)
2. Open a tracking issue on the **repository that owns the work** (see below)
3. `issue-implementation-planning` — implementation plan from the issue
4. `plan-refinement` — refine the plan
5. `review-fix-ship` — local diff review, fix, commit, push on your branch
6. `github-pr-review-triage` — after push, triage open PR review threads

Other hub packages include `ai-first-project-readiness` and
`context-token-reduction`.

**Trust boundary for `review-fix-ship`:** Default ship commits and pushes
LLM-applied fixes. Use only on branches you trust; on unfamiliar contributor
branches, use `dry-run: true` and commit yourself.

## Issues (per repository — not centralized on `.github`)

Unlike some org layouts, **platform implementation issues stay on the repo that
owns the code**:

| Work | Issue repository |
| --- | --- |
| CLI | `agents-repo/cli` (issue forms under `.github/ISSUE_TEMPLATE/`) |
| Webapp | `agents-repo/webapp` |
| Registry specs / packages | `agents-repo/registry` |
| Registry proxy | `agents-repo/registry-proxy` |
| Org-wide templates, hub catalog, git scripts | `agents-repo/.github` (plain issues) |

Gh-backed registry flows should use the **tracking issue’s repository** (for
example `agents-repo/webapp#42`). Pass optional input `repository:
owner/repo` only when the agent cannot infer the issue repo.

## Hub maintenance (from `.github` clone)

```bash
cd ~/dev/projects/agents-repo/.github
npm ci
npm run agents:install   # sync from agents.json
npm run agents:update    # refresh within semver ranges
npm run agents:verify    # lock + on-disk parity (PR baseline)
npm run agents:ci        # before changing locks or extracts locally
```

## CLI contributors verifying the hub lock

From the **cli** clone (sibling layout), after `npm run build`:

```bash
npm run agents:verify:org
```

This runs `verify` against `../.github/agents.json` without committing a
catalog in the cli repository.

## Cursor Cloud

The **Agents Repo** multi-repo environment (`.github` `environment.json`
`repositoryDependencies`) loads sibling repos for stacked rules. Registry
**skills** still come from the **`.github`** folder when that root is in the
workspace. Single-repo Cloud on webapp or cli alone will not load hub
`.cursor/skills/` — prefer the workspace file or the org Cloud environment.
See [cursor-cloud.md](cursor-cloud.md).

## Related

- [ci.md](ci.md) — which repos run `agents:verify` in PR baseline
- [CONTRIBUTING.md](../CONTRIBUTING.md) — required issue → branch → draft PR workflow
- [ecosystem.md](ecosystem.md) — repository roles
