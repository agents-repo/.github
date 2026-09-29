# Local multi-repo Git workspace

This document describes shell scripts in [`scripts/`](../scripts/) for maintaining a
**parent folder** that contains sibling clones of agents-repo repositories (for
example `registry`, `webapp`, `cli`, `registry-proxy`, and `.github`).

These scripts are **not** related to IDE instruction sync (`npm run sync:ide-instructions`
in child repos) or agents catalog install (`npm run agents:install` in this repo).

## Expected layout

```text
~/dev/projects/agents-repo/          ← workspace root (WORKSPACE_ROOT)
  .github/                           ← includes scripts/git-*.sh
  cli/
  registry/
  registry-proxy/
  webapp/
  agents-repo.github.io/             ← optional clone
```

The org meta-repo clone **should** be named `.github` (not `github` or another
alias) so gone-branch pruning can recognize the documented sibling layout
(`WORKSPACE_ROOT/.github/scripts/git-workspace-lib.sh`). Default `WORKSPACE_ROOT`
is the parent of whichever clone contains these scripts, independent of that
clone's directory name.

Discovery scans **only direct children** of the workspace root. Each child must be
a Git work tree (`git rev-parse --is-inside-work-tree`). Dot-directories such as
`.github` are included.

## Cursor / VS Code multi-root workspace

Open [`agents-repo.code-workspace`](../agents-repo.code-workspace) from **this**
clone (**File → Open Workspace from File**). Folder paths are relative to the
`.github` repository root (`../cli`, `../registry`, …).

Registry workflow skills install only in this hub — see
[org-workspace-and-agents.md](org-workspace-and-agents.md).

See [cursor-agent-worker.md](cursor-agent-worker.md) for the same sibling layout.

## npm git script aliases

From this repository root:

| Script | Shell script |
| --- | --- |
| `npm run git:sync-locals` | `scripts/git-sync-locals.sh` |
| `npm run git:fetch-all` | `scripts/git-fetch-all-branches.sh` |
| `npm run git:prune-gone` | `scripts/git-prune-gone-branches.sh` |
| `npm run git:refresh` | `scripts/git-refresh-main.sh` |

## Requirements

- Bash 4.3+ (namerefs in the shared library)
- `git` on `PATH`
- Linux, macOS, or WSL

## Workspace root

By default, `WORKSPACE_ROOT` is the parent of the `.github` clone that contains
these scripts (two levels above `scripts/`). Override when needed:

```bash
export WORKSPACE_ROOT=/path/to/agents-repo
./.github/scripts/git-refresh-main.sh
```

Recommended invocation from the workspace root:

```bash
cd ~/dev/projects/agents-repo
./.github/scripts/git-refresh-main.sh
```

Remote name defaults to `origin` (`GIT_WS_REMOTE` to override).

`WORKSPACE_ROOT` must not be `/` or your home directory unless you explicitly set
`GIT_WS_ALLOW_BROAD_ROOT=1`, because every script scans **all** direct-child git
clones under that path.

Scripts that force-delete gone local branches additionally require the documented
sibling layout (a `.github` clone containing `scripts/git-workspace-lib.sh`) unless
`GIT_WS_ALLOW_BROAD_ROOT=1`.

## Scripts

| Script | Purpose |
| --- | --- |
| [`cursor-agent-worker-start.sh`](../scripts/cursor-agent-worker-start.sh) | Start local `cursor agent worker` with `--worker-dir` for each clone ([docs](cursor-agent-worker.md)) |
| [`git-sync-locals.sh`](../scripts/git-sync-locals.sh) | `fetch --prune`, then fast-forward **existing** locals whose upstream is on `GIT_WS_REMOTE` (default `origin`) |
| [`git-fetch-all-branches.sh`](../scripts/git-fetch-all-branches.sh) | `fetch --prune`, then for each branch on `GIT_WS_REMOTE`: create a tracking local, or fast-forward when that local already tracks it; skip same-named locals with a missing or different upstream |
| [`git-prune-gone-branches.sh`](../scripts/git-prune-gone-branches.sh) | `fetch --prune`, leave gone current branch, then force-delete locals whose upstream is gone (batch confirmation) |
| [`git-refresh-main.sh`](../scripts/git-refresh-main.sh) | `fetch --prune` → checkout default → prune gone (confirm) → sync tracked locals |

Shared logic lives in [`git-workspace-lib.sh`](../scripts/git-workspace-lib.sh).

### When to use which

| Script | Typical use |
| --- | --- |
| `git-refresh-main.sh` | Frequent: stale branch cleanup, update tracking branches, end on the updated default branch in each repo |
| `git-fetch-all-branches.sh` | Occasional: after new remote branches appear that you want as local tracking branches (does not rewrite locals that track another upstream) |
| `git-sync-locals.sh` / `git-prune-gone-branches.sh` | Debugging one step; prefer `git-refresh-main.sh` for daily use |

## Safety and edge cases

### Workspace root scope

Pointing `WORKSPACE_ROOT` at a parent that contains many unrelated git clones (for
example your entire `~/dev/projects` folder) can affect every repository directly
under that directory. Prefer the agents-repo parent folder from
[Expected layout](#expected-layout). Branch pruning refuses to run when the layout
marker is missing, unless you opt in with `GIT_WS_ALLOW_BROAD_ROOT=1`.

### Pruning “gone” upstreams

After `git fetch --prune`, locals that **used to** track a remote branch on
`GIT_WS_REMOTE` but no longer have a matching `refs/remotes/<remote>/<branch>`
ref are treated as gone (detected via upstream config, not `git branch -vv`
text). If the **currently checked-out** branch is gone, the script checks out
the default branch **before** listing candidates so that branch can be included
in the same run. `git-prune-gone-branches.sh` only switches when the current
branch is gone; a live feature checkout is left unchanged.
`git-refresh-main.sh` attempts to check out the default branch before the prompt.

Before any deletion, the script lists every gone branch across the workspace
and asks once for confirmation. Confirmed branches are force-deleted with
`git branch -D`. Declining the prompt skips all deletions; when run via
`git-refresh-main.sh`, sync of remaining tracked locals still proceeds.

Locals that **never** had an upstream are not deleted.

The currently checked-out branch is still never deleted. If checkout of the
default branch fails (for example a dirty working tree), that HEAD branch is
skipped with a warning and remains.

When stdin is not a TTY (for example in CI or piped input), deletion is skipped
automatically with a warning; run the script interactively to confirm removal.

### Sync and diverged branches

Fast-forward only. Diverged locals produce a warning; the script continues with
other branches and repositories.

For the **checked-out** branch, sync uses `git merge --ff-only <GIT_WS_REMOTE>/<name>` instead of a refspec fetch (Git refuses to fetch into the current branch via refspec in many cases).

### Refresh side effects

`git-refresh-main.sh` attempts to check out the **default branch** (usually
`main`) before the gone-branch prompt, and leaves each repository there when
checkout succeeds rather than on your previous feature branch.

Checkout or merge fails on **dirty** working trees; that repository is marked
failed and processing continues. The batch exits non-zero if any repository failed.

### Default branch

Resolved from `refs/remotes/<GIT_WS_REMOTE>/HEAD` (remote defaults to `origin`),
with fallback to `main`.

## Help

Each entry script accepts `-h` / `--help` for environment variables and usage.
