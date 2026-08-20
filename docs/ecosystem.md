# Ecosystem overview

The **agents-repo** organization is an open registry and tooling stack for
agents and multi-agent flows across supported **install targets** (GitHub
Copilot, Cursor, Claude Code, and OpenAI Codex). Specifications and package
source live in the **registry** repository. **Webapp** and **CLI** consumers
read catalog files through **registry-proxy** by default (webapp and CLI can
point at GitHub or other bases via env and project config). Organization-wide
policies and this diagram live in the **[`.github`](https://github.com/agents-repo/.github)**
repository.

## System context

```mermaid
flowchart TB
  subgraph orgRepos [Platform repositories]
    Registry[registry specs and packages]
    Proxy[registry-proxy Worker]
    WebappRepo[webapp source]
    CliRepo[cli npm package]
    OrgGithub[.github org defaults]
  end

  subgraph external [External services]
    GitHub[GitHub hosting and PRs]
    Cloudflare[Cloudflare Workers edge cache]
    Npm[npm registry]
    Pages[GitHub Pages]
  end

  subgraph users [People and projects]
    Contributor[Contributors]
    EndUser[Users and developer projects]
  end

  Contributor -->|issue draft PR merge| GitHub
  GitHub --> Registry
  Registry -->|semantic-release tags| GitHub

  WebappRepo -->|CI deploy| Pages
  Pages --> Site[agents-repo.org]
  CliRepo --> Npm

  EndUser --> Site
  EndUser -->|npx agents-repo| Npm
  EndUser --> CliRun[CLI in user environment]
  CliRun -->|catalog fetch| Proxy
  Site -->|catalog fetch| Proxy
  Proxy --> Cloudflare
  Cloudflare -->|GitHub Raw or Contents API| Registry

  EndUser -->|browse tree links| GitHub
  OrgGithub -.->|policies CONTRIBUTING| Contributor
```

## Repository index

| Repository | Role |
| --- | --- |
| [registry](https://github.com/agents-repo/registry) | Normative specs, `packages/` catalog, validation and build tooling, version ZIPs |
| [registry-proxy](https://github.com/agents-repo/registry-proxy) | Read-only Cloudflare Worker: cached access to registry files and tag listing |
| [webapp](https://github.com/agents-repo/webapp) | Browse, search, and download UI; deploys to [agents-repo.org](https://agents-repo.org/) |
| [cli](https://github.com/agents-repo/cli) | Official `npx agents-repo` installer and project config (`agents.json`, lockfile) |
| [.github](https://github.com/agents-repo/.github) | Organization profile, CONTRIBUTING, security and support defaults |

Public site: [agents-repo.org](https://agents-repo.org/) (built from **webapp**;
Pages target [agents-repo.github.io](https://github.com/agents-repo/agents-repo.github.io)).

Default catalog fetch URL (webapp production and org `agents.json`):

`https://registry.agents-repo.org?ref=v2.x`

Override with webapp `VITE_*` registry settings, CLI `agents.json` / env (for
example `AGENTS_REPO_REGISTRY_URL`), or a direct GitHub source URL in development.

## Publish a package

New or updated packages are contributed to **registry** via pull request from a
contributor fork (or upstream branch for maintainers). Runtime logic stays out of
the registry; contributors add source under
`packages/<namespace>/<package-id>/`, build ZIP artifacts, and update catalog
metadata. The suggested authoring path after the draft pull request is
`full-package-creation-flow` in the registry clone (already extracted from
`agents-repo/agents-repo-package-creation`), then the same validate/build
gate. See [Submit a
package](https://agents-repo.org/docs/submitting-a-package).

```mermaid
sequenceDiagram
  participant C as Contributor
  participant F as Contributor fork
  participant GH as GitHub
  participant R as registry upstream
  participant SR as semantic-release

  C->>GH: Fork agents-repo/registry
  C->>F: Clone fork add upstream remote
  alt Tracking issue opened
    C->>GH: Open package submission issue on upstream
    C->>F: Branch package slash issue-number hyphen slug on fork
  else No tracking issue
    C->>F: Branch package slash slug on fork
  end
  C->>GH: Open draft PR fork branch to upstream main
  Note over C: Suggested full-package-creation-flow then validate-artifacts
  C->>F: Push branch commits
  C->>GH: Mark PR ready for review
  GH->>R: Squash merge feat package or fix package
  R->>SR: Release workflow on main
  SR->>GH: Git tag vMAJOR.MINOR.PATCH
  Note over R,GH: Tag versions catalog snapshot refs like v2.x
```

Squash-merge titles MUST use `feat(package):` or `fix(package):` so registry
release tags publish. See the [package submission issue
form](https://github.com/agents-repo/registry/blob/main/.github/ISSUE_TEMPLATE/package-submission.yml)
and [registry
CONTRIBUTING](https://github.com/agents-repo/registry/blob/main/.github/CONTRIBUTING.md).

## Browse or install from the catalog

Webapp and CLI both resolve a catalog ref (including major-line aliases such as
`v2.x`) and load `packages/index.json`. After that, the paths split:

- **Webapp package pages** fetch
  `packages/<namespace>/<package-id>/detail.json` (generated latest-snapshot
  aggregate; optional `readmeMarkdown`).
- **CLI install** fetches
  `packages/<namespace>/<package-id>/versions/manifest.json`, plus
  version-scoped `metadata.json` and `<version>-<target-id>.zip` artifacts
  under `packages/<namespace>/<package-id>/versions/<version>/`.

```mermaid
sequenceDiagram
  participant U as End user
  participant Site as Webapp
  participant Cli as CLI
  participant P as registry-proxy
  participant Reg as registry at ref

  alt Webapp browse
    U->>Site: Open site
    Site->>P: GET tags optional ref resolve
    P->>Reg: GitHub tags or raw content
    Site->>P: GET packages/index.json
    P->>Reg: packages/index.json
    Site->>P: GET package detail.json
    P->>Reg: latest-snapshot detail.json
    Site->>U: Search package page download UI GitHub browse links
  else CLI install
    U->>Cli: Run install
    Cli->>P: GET tags optional ref resolve
    P->>Reg: GitHub tags or raw content
    Cli->>P: GET packages/index.json
    P->>Reg: packages/index.json
    Cli->>P: GET manifest metadata ZIP paths
    P->>Reg: package version files
    Cli->>Cli: Verify SHA extract to install target paths
    Cli->>U: agents.json agents-lock.json updated
  end
```

Proxy behavior: [registry-proxy
ARCHITECTURE](https://github.com/agents-repo/registry-proxy/blob/main/docs/ARCHITECTURE.md).
CLI pipeline: [install
command](https://github.com/agents-repo/cli/blob/main/docs/commands/install.md).

Webapp fetches through the proxy (or configured base URL) but may link to the
**registry** tree on GitHub for source browsing (`VITE_REGISTRY_GITHUB_REPOSITORY_URL`).

## Install targets

Packages declare supported **install targets** in catalog metadata. The CLI
extracts version ZIPs into IDE-specific paths in the consumer project (or global
home with `-g`).

```mermaid
flowchart LR
  Zip[Version ZIP artifact]
  Zip --> Copilot["github-copilot .github agents"]
  Zip --> Cursor["cursor .cursor skills rules"]
  Zip --> Claude["claude-code .claude agents"]
  Zip --> Codex["openai-codex .agents skills"]
```

Install target IDs are normative in the registry
[`install-targets.md`](https://github.com/agents-repo/registry/blob/main/specs/install-targets.md)
spec. Marketing names: [marketing-vocabulary.md](marketing-vocabulary.md).

## Presentation decks

PDF walkthroughs (Marp source + committed PDF) live under
[`docs/slides/`](slides/README.md). Start with the
[ecosystem overview](slides/pdf/ecosystem-overview.pdf) and
[contributing workflow](slides/pdf/contributing-workflow.pdf) decks, then the
per-repo indexes linked from that slides README.

## Related links

- Organization [Required Workflow](../CONTRIBUTING.md#required-workflow)
- Organization [branch prefix reference](../CONTRIBUTING.md#branch-prefix-reference)
- [Registry package submission](https://github.com/agents-repo/registry/issues/new/choose)
- [Webapp development](https://github.com/agents-repo/webapp/blob/main/docs/development.md)
- [CLI architecture](https://github.com/agents-repo/cli/blob/main/docs/ARCHITECTURE.md)
- [Webapp deployment](https://github.com/agents-repo/webapp/blob/main/docs/deployment.md)
