# Roadmap

Direction for the **agents-repo** ecosystem. Outcomes only — no dates or delivery
promises. GitHub issues and merged pull requests are the source of truth for
active work.

## How to use this doc

- **Now** lists outcomes with filed tracking issues.
- **Next** and **Later** describe near- and long-term intent without issue
  numbers unless work is already tracked elsewhere.
- **Exploring** holds ideas we are not committing to yet.
- Shipped work is verified via merged PRs and release tags, not this file alone.
- Propose changes by opening or discussing issues in the relevant repository.

## Now

Active FOSS UX and contributor-experience outcomes.

### Webapp

- Install-first home activation (hero, CTAs, five-step how-it-works) —
  [agents-repo/webapp#283](https://github.com/agents-repo/webapp/issues/283)
- Unified `/contribute` contributor hub —
  [agents-repo/webapp#284](https://github.com/agents-repo/webapp/issues/284)
- Package trust signals and error recovery —
  [agents-repo/webapp#285](https://github.com/agents-repo/webapp/issues/285)
- Catalog discovery polish (install on cards, “Start here”, search match context) —
  [agents-repo/webapp#286](https://github.com/agents-repo/webapp/issues/286)
- Share metadata with install command in social previews —
  [agents-repo/webapp#287](https://github.com/agents-repo/webapp/issues/287)
- Author and AI discoverability doc updates —
  [agents-repo/webapp#288](https://github.com/agents-repo/webapp/issues/288)

### CLI

- CLI ↔ webapp command inventory sync check —
  [agents-repo/cli#133](https://github.com/agents-repo/cli/issues/133)

### Registry & specs

- No separate registry issues in this batch; author doc updates in
  [webapp#288](https://github.com/agents-repo/webapp/issues/288) link to
  [registry specs](https://github.com/agents-repo/registry/tree/main/specs).

### Community

- Contributor hub and doc updates above improve FOSS onboarding paths on the
  public site without replacing per-repository CONTRIBUTING guides.

## Next

Near-term follow-ons after the current epic batch.

### Webapp

- Cross-link this roadmap from About, `/contribute`, and docs once the hub ships
  ([webapp#284](https://github.com/agents-repo/webapp/issues/284)).

### CLI

- Close remaining npm-parity gaps called out in CLI docs (for example global
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
  [webapp#285](https://github.com/agents-repo/webapp/issues/285) constraints.

### CLI

- Automated doc codegen across repositories (related:
  [cli#133](https://github.com/agents-repo/cli/issues/133) explores inventory
  sync, not full codegen).

### Registry & specs

- Custom collaborative namespaces via `owners.json` — see
  [registry `NAMESPACE_RULES.md`](https://github.com/agents-repo/registry/blob/main/NAMESPACE_RULES.md#future-custom-namespaces-not-implemented).

### Community

- North Star metrics documentation.
- GitHub Projects automation or board sync for roadmap tracking (out of scope
  for this document).
