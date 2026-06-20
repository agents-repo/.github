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
| [.github](https://github.com/agents-repo/.github) | Organization-wide defaults | This repository — open an issue or pull request here |

## Shared norms

These norms apply across the organization unless a repository guide specifies otherwise.

1. Open an issue before implementation when the repository uses issue-driven workflow. Use the matching issue form when available.
2. Create branches from the latest default branch using `<prefix>/<issue-number>-<slug>`, where `<slug>` is short lowercase kebab-case.
3. Prefer the [`gh` CLI](https://cli.github.com/) for issue and pull request communication.
4. Use conventional commit prefixes such as `feat`, `fix`, `docs`, `chore`, `refactor`, `perf`, `test`, `build`, `ci`, and `revert`.
5. Keep pull requests focused and include validation evidence required by the target repository.

When this document conflicts with a repository's own `CONTRIBUTING.md`, the repository guide takes precedence.

## Changing organization-wide defaults

To update community health files, templates, or other shared configuration for the organization, open an issue or pull request in [agents-repo/.github](https://github.com/agents-repo/.github).

For help choosing the right repository or channel, see [SUPPORT.md](SUPPORT.md).
