# Cursor Cloud environments

Organization repositories can run as Cursor Cloud Agents, either one repo at a
time or as the **Agents Repo** multi-repo environment (this `.github` clone plus
`cli`, `registry`, `registry-proxy`, `webapp`, and the Pages deploy target
`agents-repo.github.io`).

## Repository-managed config

Each development repository commits `.cursor/environment.json`. Cursor prefers
that file over a dashboard personal or team environment when it is present.

| Repository | Role |
| --- | --- |
| `.github` (this repo) | Multi-repo bootstrap. `install` runs `HUSKY=0 npm ci --ignore-scripts` here, then each sibling's `.cursor/install.sh` when that file is present. `repositoryDependencies` lists the other organization repos so generated GitHub tokens can reach them. |
| `cli`, `registry`, `registry-proxy`, `webapp` | Single-repo bootstrap (`HUSKY=0 npm ci` after activating pinned Node/npm). |
| `agents-repo.github.io` | Not a development repo. Do not add Cloud install here. |

Install scripts must be idempotent and must terminate. They must not start
dev servers. The webapp Vite server belongs in `terminals` on that repository.

## Pinned toolchain

Development repos pin Node **24.18.0** (`.nvmrc` where present) and npm
**12.0.1** (`package.json` `packageManager`). `.github`, registry, webapp, and
registry-proxy `env:check` scripts require the exact Node patch.

Cursor Cloud VMs may put `/exec-daemon/node` (Node 22) ahead of nvm on
`PATH`. Before running repo scripts, prepend the pinned Node bin:

```bash
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"
nvm use
export PATH="$(dirname "$(nvm which 24.18.0)"):$PATH"
```

Do not use `nvm which current` on Cloud VMs; it can resolve to
`/exec-daemon/node`.

`.cursor/install.sh` does this automatically during environment builds.

## Multi-repo workspace (intentional)

The **Agents Repo** environment loads all sibling repositories listed in
`repositoryDependencies`. Each repo contributes one `alwaysApply` Cursor rule;
that stacking is intentional so contributors working in any child repo still
see org and sibling norms. Do not switch to a single-repo workspace to save
tokens unless the task is strictly local to one repository.

## `.cursorignore` template

Each development repository SHOULD commit a root `.cursorignore` to keep
lockfiles, build output, caches, and large artifacts out of the Cursor indexer.
Do **not** ignore normative sources agents need (`specs/`, `packages/` source
trees, registry skill extract paths).

Shared baseline (tune per repo):

```gitignore
node_modules/
package-lock.json
.cache/
dist/
coverage/
```

| Repository | Additional entries |
| --- | --- |
| `.github` | `docs/slides/pdf/` |
| `registry` | `packages/**/versions/**/*.zip`, target-specific package ZIP globs |
| `webapp` | `playwright-report/`, `test-results/` |
| `registry-proxy` | `.wrangler/`, `docs/slides/build/` |

## Path-scoped Copilot instructions

GitHub Copilot loads `.github/instructions/*.instructions.md` when `applyTo`
matches edited paths. Use short bullets and doc links—not pasted workflow
walls. Reference implementations:

- `registry-proxy/.github/instructions/` (worker, deploy, migrate, release)
- `cli/.github/instructions/` (src, specs, commands docs)
- `webapp/.github/instructions/` (src, e2e, accessibility)

Point to these from `.github/copilot-instructions.md`; do not duplicate bodies
in always-on IDE mirrors.
