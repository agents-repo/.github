---
marp: true
theme: agents-repo
paginate: true
---

<!-- _class: title -->

# agents-repo ecosystem

Open registry and tooling for agents and multi-agent flows

agents-repo.org

---

# What this org is

- An **open registry** for agents and multi-agent flows
- Distributed to **install targets** (AI coding tools)
- Specs and package source live in **registry**
- Webapp and CLI fetch the catalog through **registry-proxy** by default

Not “Copilot agents only.” Product voice: install targets and AI coding tools.

---

# Install targets

Marketing list order:

1. GitHub Copilot
2. Cursor
3. Claude Code
4. OpenAI Codex

Normative IDs live in the registry `install-targets` spec. Display names live in
org `docs/marketing-vocabulary.md`.

---

# Repositories

| Repo | Role |
| --- | --- |
| registry | Specs, `packages/` catalog, ZIP artifacts |
| registry-proxy | Cached read-only Worker for registry files |
| webapp | Browse / search / download → agents-repo.org |
| cli | `npx agents-repo` install and project config |
| .github | Org profile, CONTRIBUTING, this convention |

---

# How the pieces fit

1. Contributors publish packages to **registry** via GitHub pull request
2. **semantic-release** tags catalog snapshots (for example `v2.x`)
3. **webapp** and **cli** resolve a catalog ref
4. Default fetch URL is **registry-proxy** (overridable in env / config)
5. Public site is **webapp** deployed to GitHub Pages

---

# Publish a package (high level)

- Fork **agents-repo/registry** (external contributors)
- Add source under `packages/<namespace>/<package-id>/`
- Validate, build ZIPs, update catalog metadata
- Draft PR → human marks ready → squash `feat(package):` or `fix(package):`

Runtime logic stays **out of** the registry.

---

# Browse vs install

**Webapp** (agents-repo.org)

- `packages/index.json` then package `detail.json`

**CLI** (`npx agents-repo`)

- `packages/index.json` then `versions/manifest.json`
- Version `metadata.json` and `<version>-<target-id>.zip`

Same catalog, different paths after the index.

---

# Default catalog URL

Production webapp and org `agents.json`:

`https://registry-proxy.maiconfz.workers.dev?ref=v2.x`

Override with webapp `VITE_*` settings, CLI `agents.json` / env
(`AGENTS_REPO_REGISTRY_URL`), or a direct GitHub source in development.

---

# Install targets on disk

The CLI extracts each ZIP into IDE-specific paths:

- GitHub Copilot → `.github/agents`
- Cursor → `.cursor/skills` and rules
- Claude Code → `.claude/agents`
- OpenAI Codex → `.agents/skills`

IDs are normative in registry specs; do not invent new ones in slides.

---

# Public site

- **agents-repo.org** — user guides, package browser, repo pages
- Built from **webapp**
- Pages target **agents-repo.github.io** (not a development repo)

Org docs also live in this `.github` repository
(`docs/ecosystem.md`, `CONTRIBUTING.md`).

---

# Specs live in registry

Normative rules (package format, agent/flow files, manifests, versioning)
are in `agents-repo/registry` `specs/`.

This org repo holds **policies and orientation**, not those contracts.

---

# Deeper decks

| Topic | Repository |
| --- | --- |
| Package creation | registry |
| Webapp infrastructure | webapp |
| CLI usage | cli |
| Proxy architecture | registry-proxy |

Each repo keeps source + PDF under `docs/slides/`.

---

# Links

- Site: [https://agents-repo.org](https://agents-repo.org)
- Ecosystem doc: `.github` `docs/ecosystem.md`
- Registry specs: `agents-repo/registry` `specs/`
- Contributing: org `CONTRIBUTING.md` (and the workflow deck)

---

<!-- _class: closing -->

# Next

Read `docs/ecosystem.md`, then pick a platform deck.

Questions: [https://agents-repo.org/contact](https://agents-repo.org/contact)
