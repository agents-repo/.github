# Roadmap

Direction for the **agents-repo** ecosystem. Outcomes only — no dates or delivery
promises. GitHub issues and merged pull requests are the source of truth for
active work.

## How to use this doc

- **Now** lists outcomes with filed tracking issues. It MAY be empty between
  epics. When a batch ships, remove those issues from **Now**.
- **Next** and **Later** describe near- and long-term intent without issue
  numbers unless work is already tracked elsewhere.
- **Exploring** holds ideas we are not committing to yet.
- Shipped work is verified via merged PRs and release tags, not this file alone.
- Propose changes by opening or discussing issues in the relevant repository.

## Now

No multi-repo epic is listed here. Open issues in each repository remain the
source of truth for active work.

The FOSS UX / contributor-hub batch is complete: install-first home,
`/contribute`, package trust and error recovery, catalog discovery polish,
share metadata, author and AI docs, and CLI ↔ webapp command inventory check.

## Next

Near-term follow-ons after the shipped FOSS UX batch.

### CLI

- Close remaining npm-parity gaps called out in CLI docs (for example, global
  `ci`/`doctor`, extended install aliases) as individual issues land.

### Registry & specs

- Package-author ergonomics and validation tooling improvements beyond the
  current FOSS UX batch.

### Community

- Clearer contributor onboarding paths on the public site tied to organization
  repositories (without duplicating full CONTRIBUTING bodies).

## Later

Longer-horizon platform outcomes.

### Registry & specs

- Richer catalog metadata and package lifecycle features that require spec
  changes.

### CLI

- Interactive install-from-search and broader project-management commands.

### Webapp

- Deeper personalization or recommendation once catalog scale justifies it
  (not semantic search or ML recommendations in the current epic constraints).

### Community

- Expanded governance and maintainer tooling as the organization grows.

## Exploring

Ideas under consideration; not committed. Do not treat these as scheduled work.

### Webapp

- Per-package Open Graph images (dynamic generation).
- GitHub activity feeds on package detail pages.
- Category landing pages (the catalog has roughly three categories today).
- Subjective trust signals (GitHub stars, quality scores) — see
  [agents-repo/webapp#285](https://github.com/agents-repo/webapp/issues/285) constraints.

### CLI

- Automated doc codegen across repositories (related:
  [agents-repo/cli#133](https://github.com/agents-repo/cli/issues/133) explores inventory
  sync, not full codegen).

### Registry & specs

- Custom collaborative namespaces via `owners.json` — see
  [registry `NAMESPACE_RULES.md`](https://github.com/agents-repo/registry/blob/main/NAMESPACE_RULES.md#future-custom-namespaces-not-implemented).

### Community

- North Star metrics documentation.
- GitHub Projects automation or board sync for roadmap tracking (out of scope
  for this document).
