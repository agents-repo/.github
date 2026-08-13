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

Discovery scans **only direct children** of the workspace root. Each child must be
a Git work tree (`git rev-parse --is-inside-work-tree`). Dot-directories such as
`.github` are included.

## Requirements

- Bash 4+
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

## Scripts

| Script | Purpose |
| --- | --- |
| [`git-sync-locals.sh`](../scripts/git-sync-locals.sh) | `fetch --prune`, then fast-forward **existing** local branches that track `origin/*` |
| [`git-fetch-all-branches.sh`](../scripts/git-fetch-all-branches.sh) | `fetch --prune`, then create or update a local branch for **every** `origin` branch |
| [`git-prune-gone-branches.sh`](../scripts/git-prune-gone-branches.sh) | `fetch --prune`, leave gone current branch, then force-delete locals whose upstream is gone (batch confirmation) |
| [`git-refresh-main.sh`](../scripts/git-refresh-main.sh) | `fetch --prune` → checkout default → prune gone (confirm) → sync tracked locals |

Shared logic lives in [`git-workspace-lib.sh`](../scripts/git-workspace-lib.sh).

### When to use which

| Script | Typical use |
| --- | --- |
| `git-refresh-main.sh` | Frequent: stale branch cleanup, update tracking branches, end on updated `main` everywhere |
| `git-fetch-all-branches.sh` | Occasional: after new remote branches appear that you want as local tracking branches |
| `git-sync-locals.sh` / `git-prune-gone-branches.sh` | Debugging one step; prefer `git-refresh-main.sh` for daily use |

## Safety and edge cases

### Pruning “gone” upstreams

After `git fetch --prune`, locals that **used to** track a remote branch on
`GIT_WS_REMOTE` but no longer have a matching `refs/remotes/<remote>/<branch>`
ref are treated as gone (detected via upstream config, not `git branch -vv`
text). If the **currently checked-out** branch is gone, the script checks out
the default branch **before** listing candidates so that branch can be included
in the same run. `git-prune-gone-branches.sh` only switches when the current
branch is gone; a live feature checkout is left unchanged.
`git-refresh-main.sh` always checks out the default branch before the prompt.

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

For the **checked-out** branch, sync uses `git merge --ff-only origin/<name>`
instead of a refspec fetch (Git refuses to fetch into the current branch via
refspec in many cases).

### Refresh side effects

`git-refresh-main.sh` checks out the **default branch** (usually `main`) before
the gone-branch prompt, and leaves each repository there rather than on your
previous feature branch.

Checkout or merge fails on **dirty** working trees; that repository is marked
failed and processing continues. The batch exits non-zero if any repository failed.

### Default branch

Resolved from `refs/remotes/origin/HEAD`, with fallback to `main`.

## Help

Each entry script accepts `-h` / `--help` for environment variables and usage.
