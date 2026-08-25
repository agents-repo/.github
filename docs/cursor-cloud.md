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
**12.0.1** (`package.json` `packageManager`). Registry, webapp, and
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
