# Development — organization `.github` repository

This repository holds organization-wide community health files, shared
configuration, presentation slides, and the multi-repo Cursor Cloud workspace
manifest. It is not an application runtime.

## First steps

1. Read [CONTRIBUTING.md](../CONTRIBUTING.md) for the required issue → branch →
   draft PR workflow.
2. Read [`.cursor/rules/agents-org.mdc`](../.cursor/rules/agents-org.mdc)
   (canonical agent instructions).
3. Before editing shared scripts or Sonar-prone JavaScript, read
   [ai-static-analysis-patterns.md](ai-static-analysis-patterns.md).
4. For ecosystem context, see [ecosystem.md](ecosystem.md),
   [org-workspace-and-agents.md](org-workspace-and-agents.md), [ci.md](ci.md), and
   [cursor-cloud.md](cursor-cloud.md).
5. For a local private agent worker over sibling clones, see
   [cursor-agent-worker.md](cursor-agent-worker.md).

## Validation

Always-on local handoff for this repository:

```bash
npm run lint:all
npm run sync:ide-instructions -- --check
```

Optional local duplication scan (not CI; see
[ai-static-analysis-patterns.md — jscpd](ai-static-analysis-patterns.md#local-duplication-checks-jscpd)):

```bash
npm run dup:check
npm run dup:check:workspace
```

Optional runtime pin check:

```bash
npm run env:check
```

Path-filtered extras (see [CONTRIBUTING — PR baseline extras](../CONTRIBUTING.md#pr-baseline-extras-path-filters)):

- `npm run slides:check` — when `docs/slides/**` or `scripts/slides.mjs` change
- `npm run agents:verify` — when `agents.json`, `agents-lock.json`, or extracted agent paths change (PR baseline parity)

## What to edit

| Change type | Canonical files |
| --- | --- |
| Agent instructions | `.cursor/rules/agents-org.mdc` → `npm run sync:ide-instructions` |
| Contributor workflow | `CONTRIBUTING.md` |
| Presentation decks | `docs/slides/*.md` → `npm run slides:build` / `slides:check` |
| Registry workflow packages | `agents.json` → `npm run agents:install` / `agents:verify` / `agents:ci` |
| GitHub Actions | `.github/workflows/` → `npm run lint:workflows` |

## Child repository instructions

Each application repository maintains its own `.cursor/rules/agents-*.mdc`.
See the agent instruction matrix in [CONTRIBUTING.md](../CONTRIBUTING.md#agent-instruction-files).
