# Presentation slides

Marp PDF decks for the agents-repo organization. **Commit PDF only** — do not
commit HTML. HTML preview is a local convenience under `docs/slides/build/`
(gitignored).

Authoring: [Marp](https://marp.app/). The
[Marp for VS Code](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode)
extension previews `.md` decks in the editor.

## Layout

| Path | Role |
| --- | --- |
| `docs/slides/*.md` | Deck source (not `README.md`) |
| `docs/slides/theme/theme.css` | Shared `@theme agents-repo` |
| `docs/slides/pdf/<stem>.pdf` | Committed PDF artifact |
| `docs/slides/pdf/<stem>.src.sha256` | Source fingerprint for `slides:check` |
| `docs/slides/build/` | Local HTML preview (not committed) |

## Org decks in this repository

| Deck | PDF | Audience |
| --- | --- | --- |
| [ecosystem-overview.md](ecosystem-overview.md) | [ecosystem-overview.pdf](pdf/ecosystem-overview.pdf) | New contributors and partners |
| [contributing-workflow.md](contributing-workflow.md) | [contributing-workflow.pdf](pdf/contributing-workflow.pdf) | Contributors and coding agents |

Platform decks (copy theme and scripts from this repository):

- [registry](https://github.com/agents-repo/registry/blob/main/docs/slides/README.md)
- [webapp](https://github.com/agents-repo/webapp/blob/main/docs/slides/README.md)
- [cli](https://github.com/agents-repo/cli/blob/main/docs/slides/README.md)
- [registry-proxy](https://github.com/agents-repo/registry-proxy/blob/main/docs/slides/README.md)

## Frontmatter defaults

Every deck MUST start with:

```yaml
---
marp: true
theme: agents-repo
paginate: true
---
```

Optional: `<!-- _class: title -->` or `<!-- _class: closing -->` on a slide.
Keep decks PDF-oriented; do not add HTML-only features that break print.

## Scripts

| Script | Purpose |
| --- | --- |
| `npm run slides:build` | Write PDFs and source fingerprints under `docs/slides/pdf/` |
| `npm run slides:preview:html` | Write HTML under `docs/slides/build/` (gitignored) |
| `npm run slides:check` | Fail if a deck source drifted from the committed fingerprint, a PDF is missing or not a PDF, or Chrome cannot rebuild PDFs |

`slides:check` hashes Marp HTML (deterministic, no browser) rather than raw PDF
bytes. Chrome PDF output is not bit-stable across machines or Chrome versions,
so CI does **not** require the committed PDF bytes to match the rebuild. It
still checks minimum size and a `%PDF-` header, rebuilds in a temp directory,
and reports source-fingerprint drift even when a rebuild throws.

Reviewers MUST inspect diffs to `docs/slides/pdf/*.pdf`. A green `slides:check`
does not prove the committed PDF was produced from the Markdown source.

After editing a deck, run `npm run slides:build` and commit the updated
`docs/slides/pdf/` files.

## Theme sync

Platform repositories SHOULD copy `docs/slides/theme/theme.css` and
`scripts/slides.mjs` from this repository when they add decks. Re-copy after
theme or script changes here.

## Local Chromium / PDF notes

PDF conversion needs Google Chrome or Chromium.

- **Linux:** install `chromium` or Google Chrome. Or set
  `PUPPETEER_EXECUTABLE_PATH` / `CHROME_PATH` to the binary. Ubuntu 23.10+ and
  GitHub-hosted runners disable the Chromium sandbox; `slides.mjs` sets
  `CHROME_NO_SANDBOX=1` on Linux and when `CI` is set (Marp CLI then launches
  Chrome with `--no-sandbox`).
- **macOS:** Google Chrome at
  `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` is detected.
- **CI:** `browser-actions/setup-chrome` sets `PUPPETEER_EXECUTABLE_PATH`. The
  workflow also sets `CHROME_NO_SANDBOX=1`.

If `slides:build` or `slides:check` reports that Chrome was not found, install
a browser or set one of those environment variables. If Chrome reports "No
usable sandbox", export `CHROME_NO_SANDBOX=1`.

Do not commit `docs/slides/build/`.
