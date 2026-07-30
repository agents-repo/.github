# Marketing and install-target vocabulary

Organization-wide guidance for **product voice**, **install targets**, and
**SEO** in platform repositories. Normative IDs and ZIP rules live in the
registry — do not redefine them here.

Technical reference: [install-targets.md](https://github.com/agents-repo/registry/blob/main/specs/install-targets.md)

## Product voice

- Describe the product as an **open registry for agents and multi-agent flows**.
- Use **install targets** and **AI coding tools** in marketing and docs.
- Do **not** define the product as “Copilot agents” or “GitHub Copilot agents”
  only.

## Canonical install targets

| ID | Display name (prose) |
| --- | --- |
| `github-copilot` | GitHub Copilot |
| `cursor` | Cursor |
| `claude-code` | Claude Code |
| `openai-codex` | OpenAI Codex |

**Marketing list order:** GitHub Copilot, Cursor, Claude Code, OpenAI Codex.

## Three different “Copilot” meanings (do not conflate)

1. **Install target** — `github-copilot` / GitHub Copilot (IDE agent surface).
2. **Contributor file** — `.github/copilot-instructions.md` (GitHub’s filename
   convention for project instructions).
3. **GitHub PR review** — GitHub Copilot or Bugbot commenting on pull requests;
   not an install target.

## Contributor tooling

Document install-target → path mappings factually (for example Copilot agent
paths, Cursor skills/rules) without preferring one vendor in **product**
positioning sentences.

Repositories that mirror project guidelines from
`.github/copilot-instructions.md` may also generate `CLAUDE.md` (Claude Code) and
`AGENTS.md` (OpenAI Codex) via `npm run sync:ide-instructions`. These filenames
follow each tool's convention for repo-level instructions; they are contributor
files, not install targets.

## Catalog packages (out of scope)

Marketing copy under `registry/packages/**` (`index.json`, package READMEs,
metadata) is **out of scope** for this vocabulary initiative unless a separate
task explicitly targets catalog content.

## SEO

- Prefer one concise multi-tool mention per meta description where possible.
- Webapp static route meta descriptions MUST stay **≤ 160 characters** (see
  webapp `siteSeoMeta` tests).

## npm keywords (CLI)

- Prefer canonical id `openai-codex`.
- Optional `codex` for discovery.
- Optional `github-copilot` / `copilot` for GitHub Copilot search.
