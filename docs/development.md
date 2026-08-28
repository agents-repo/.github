# Development — organization `.github` repository

This repository holds organization-wide community health files, shared
configuration, presentation slides, and the multi-repo Cursor Cloud workspace
manifest. It is not an application runtime.

## First steps

1. Read [CONTRIBUTING.md](../CONTRIBUTING.md) for the required issue → branch →
   draft PR workflow.
2. Read [`.github/copilot-instructions.md`](../.github/copilot-instructions.md)
   (canonical agent instructions).
3. For ecosystem context, see [ecosystem.md](ecosystem.md) and
   [cursor-cloud.md](cursor-cloud.md).

## Validation

Always-on local handoff for this repository:

```bash
npm run lint:all
npm run sync:ide-instructions -- --check
```

Optional runtime pin check:

```bash
npm run env:check
```

Path-filtered extras (see [CONTRIBUTING — PR baseline extras](../CONTRIBUTING.md#pr-baseline-extras-path-filters)):

- `npm run slides:check` — when `docs/slides/**` or `scripts/slides.mjs` change
- `npm run agents:ci` — when `agents.json`, lockfile, or extracted agent paths change

## What to edit

| Change type | Canonical files |
| --- | --- |
| Agent instructions | `.github/copilot-instructions.md` → `npm run sync:ide-instructions` |
| Contributor workflow | `CONTRIBUTING.md` |
| Presentation decks | `docs/slides/*.md` → `npm run slides:build` / `slides:check` |
| Registry workflow packages | `agents.json` → `npm run agents:install` / `agents:ci` |
| GitHub Actions | `.github/workflows/` → `npm run lint:workflows` |

## Child repository instructions

Each application repository maintains its own `.github/copilot-instructions.md`.
See the agent instruction matrix in [CONTRIBUTING.md](../CONTRIBUTING.md#agent-instruction-files).
