# Contributing

Thanks for contributing to the agents-repo ecosystem.

By contributing to this organization, you agree that your contributions are licensed under the [MIT License](LICENSE) unless a repository specifies a different license.

## Code of Conduct

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold it.

## Security

Do not report security vulnerabilities in public issues, discussions, or pull requests. See [SECURITY.md](SECURITY.md) for private reporting instructions.

## Where to contribute

Choose the repository that matches the kind of work you want to do, then follow that repository's detailed contributing guide.

| Repository | Purpose | Detailed guide |
| --- | --- | --- |
| [registry](https://github.com/agents-repo/registry) | Specs, schemas, packages | [`.github/CONTRIBUTING.md`](https://github.com/agents-repo/registry/blob/main/.github/CONTRIBUTING.md) |
| [webapp](https://github.com/agents-repo/webapp) | Registry UI | [`.github/CONTRIBUTING.md`](https://github.com/agents-repo/webapp/blob/main/.github/CONTRIBUTING.md) |
| [registry-proxy](https://github.com/agents-repo/registry-proxy) | Cloudflare Worker proxy | [`.github/CONTRIBUTING.md`](https://github.com/agents-repo/registry-proxy/blob/main/.github/CONTRIBUTING.md) |
| [.github](https://github.com/agents-repo/.github) | Organization-wide defaults | This repository — open an issue before implementation here |
| [agents-repo.github.io](https://github.com/agents-repo/agents-repo.github.io) | Automated Pages deploy target for webapp (not a development repo) | See [webapp deployment docs](https://github.com/agents-repo/webapp/blob/main/docs/deployment.md) |

## Required Workflow

Every task in an active development repository MUST follow this full lifecycle.

### Task setup (before implementation)

1. **Issue first** — Open a tracking issue (matching issue form when available)
   before any implementation work.
2. **Branch second** — Create a non-`main` branch named
   `<prefix>/<issue-number>-<slug>` from the latest `main`.
3. **Push and draft PR third** — Push the branch, then open a **draft** pull
   request targeting `main` before implementation commits. Pull requests MUST
   be created as drafts (`gh pr create --draft` or the GitHub UI draft
   option). Do not open a non-draft pull request at creation time. In
   `## Related Issues`, include `Closes #<issue-number>` for standard tasks,
   or follow **Workflow exceptions** for security-advisory references.

GitHub cannot open a pull request when the head and base branches are
identical. Before `gh pr create --draft`, push at least one commit on the task
branch so its head differs from `main` (for example
`git commit --allow-empty -m "chore: scaffold draft PR for #<issue-number>"`).
An empty commit is sufficient when no file changes are needed yet.
Implementation commits may follow on the same branch.

### Delivery (after draft PR)

1. **Implement and validate** — Push implementation commits to the task branch
   and run the target repository's validation commands.
2. **Ready for review** — After validation passes, the developer manually
   marks the pull request ready for review in GitHub. Agents and automation
   MUST NOT mark pull requests ready for review.
3. **PR-only `main`** — All integration to `main` MUST happen via merged pull
   request. Direct commits or pushes to `main` MUST NOT be used (humans and
   agents).
4. **Agent handoff** — Agents complete requested implementation work on the
   task branch, then hand off. Human developers mark pull requests ready for
   review after validation; maintainers merge. Agents MUST NOT mark pull
   requests ready for review or merge to `main`.

## Workflow exceptions

1. **Security vulnerabilities** — Follow [SECURITY.md](SECURITY.md); do not
   open public tracking issues. Use the private advisory flow. Branch and draft
   pull request are still required before merge to `main`. In `## Related
   Issues`, use `Closes #<issue-number>` when maintainers provide a linked
   private or advisory tracking issue. Otherwise, reference the private
   security advisory identifier (for example `GHSA-...`) in the PR body and
   coordinate linkage with maintainers.
2. **Maintainer emergency hotfix** — Work on a hotfix branch only with prior
   maintainer approval documented in an issue or advisory. Delivery to `main`
   is still via merged pull request (no direct push).
3. **Organization `.github` repository** — Plain issues are acceptable (no issue
   forms). Issue, branch, and draft pull request are still required.

## Shared norms

These norms apply across the organization unless a repository guide specifies
otherwise.

1. Follow the Required Workflow above for every implementation task.
2. Create branches from the latest default branch using
   `<prefix>/<issue-number>-<slug>`, where `<slug>` is short lowercase
   kebab-case.
3. Prefer the [`gh` CLI](https://cli.github.com/) for issue and pull request
   communication.
4. Issue forms capture intent only; use the number GitHub assigns after
   submission when naming branches and writing PR `## Related Issues`—do not
   edit issue bodies to add the number.
5. Use conventional commit prefixes such as `feat`, `fix`, `docs`, `chore`,
   `refactor`, `perf`, `test`, `build`, `ci`, and `revert`.
6. Keep pull requests focused and include validation evidence required by the
   target repository.
7. All contributors MUST integrate changes to the default branch only through
   merged pull requests. AI agents MUST NOT merge pull requests into the
   default branch or push commits directly to it. Integration to the default
   branch is a human-only step after review.

When this document conflicts with a repository's own `CONTRIBUTING.md`, the repository guide takes precedence.

## Agent instruction files

| Repository | GitHub Copilot | Cursor |
| --- | --- | --- |
| [registry](https://github.com/agents-repo/registry) | `.github/copilot-instructions.md` | `.cursor/rules/agents-registry.mdc` |
| [webapp](https://github.com/agents-repo/webapp) | `.github/copilot-instructions.md` | `.cursor/rules/agents-webapp.mdc` |
| [registry-proxy](https://github.com/agents-repo/registry-proxy) | `.github/copilot-instructions.md` | `.cursor/rules/agents-registry-proxy.mdc` |
| [.github](https://github.com/agents-repo/.github) (this repo) | `.github/copilot-instructions.md` | `.cursor/rules/agents-org.mdc` |

Registry, webapp, and registry-proxy regenerate Cursor rules with
`npm run sync:cursor-rules` after editing `.github/copilot-instructions.md`. This
repository keeps Copilot and Cursor files aligned manually in the same change
(Pattern B — no npm sync tooling).

## Changing organization-wide defaults

To update community health files, templates, or other shared configuration for
the organization, open an issue before implementation in
[agents-repo/.github](https://github.com/agents-repo/.github).

For help choosing the right repository or channel, see [SUPPORT.md](SUPPORT.md).

## Maintainer enforcement

Documentation alone cannot prevent direct pushes to `main`. Maintainers SHOULD
enforce the PR-only policy on `main` with GitHub branch protection or
repository rulesets for these active development repositories:

- `agents-repo/.github`
- `agents-repo/registry`
- `agents-repo/webapp`
- `agents-repo/registry-proxy`

Recommended settings (via branch protection or rulesets):

1. **Require a pull request before merging** — all integration to `main` goes
   through review and merge.
2. **Block direct pushes to `main`** — enforce the PR-only policy at the
   platform level.
3. **Require status checks to pass** — enable required CI workflows where
   available (for example PR baseline, lint, test, and typecheck jobs).

`agents-repo.github.io` is excluded; it is an automated deployment target for
the webapp, not a development repository.

Configuring branch protection or rulesets is a maintainer action in GitHub
repository settings and is not applied by changes in this repository.
