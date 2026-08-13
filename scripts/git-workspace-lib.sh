# shellcheck shell=bash
# Shared helpers for multi-repo git workspace maintenance.
# Source this file; do not execute directly.

GIT_WS_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "${WORKSPACE_ROOT:-}" ]]; then
  WORKSPACE_ROOT="$(cd "${GIT_WS_LIB_DIR}/../.." && pwd)"
fi

GIT_WS_FAILED=0
GIT_WS_REMOTE="${GIT_WS_REMOTE:-origin}"

set -o pipefail 2>/dev/null || true

log_info() {
  printf '==> %s\n' "$*"
  return 0
}

log_warn() {
  printf 'warning: %s\n' "$*" >&2
  return 0
}

log_err() {
  printf 'error: %s\n' "$*" >&2
  return 0
}

mark_failed() {
  GIT_WS_FAILED=1
  return 0
}

validate_workspace_config() {
  local resolved

  if [[ ! "$GIT_WS_REMOTE" =~ ^[A-Za-z0-9._-]+$ ]]; then
    log_err "invalid GIT_WS_REMOTE (use only letters, digits, ., _, -): ${GIT_WS_REMOTE}"
    exit 1
  fi

  if [[ ! -d "$WORKSPACE_ROOT" ]]; then
    log_err "WORKSPACE_ROOT is not a directory: ${WORKSPACE_ROOT}"
    exit 1
  fi

  resolved="$(cd "$WORKSPACE_ROOT" && pwd -P)"
  if [[ "$resolved" == "/" ]] || [[ "$resolved" == "${HOME}" ]]; then
    log_warn "WORKSPACE_ROOT is broad (${resolved}); confirm this is intentional"
  fi

  return 0
}

require_git() {
  if ! command -v git >/dev/null 2>&1; then
    log_err "git not found on PATH"
    exit 1
  fi
  validate_workspace_config
  return 0
}

is_git_repo() {
  local dir="$1"
  if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

# Prints absolute paths to direct-child git clones under WORKSPACE_ROOT (sorted).
discover_git_repos() {
  local dir
  while IFS= read -r -d '' dir; do
    if is_git_repo "$dir"; then
      printf '%s\n' "$dir"
    fi
  done < <(
    LC_ALL=C find "$WORKSPACE_ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z
  )
  return 0
}

repo_header() {
  local repo_path="$1"
  log_info "[$(basename "$repo_path")] $repo_path"
  return 0
}

resolve_default_branch() {
  local default=""
  default="$(
    git symbolic-ref --short "refs/remotes/${GIT_WS_REMOTE}/HEAD" 2>/dev/null \
      | sed "s|^${GIT_WS_REMOTE}/||"
  )"
  if [[ -z "$default" ]]; then
    default="main"
  fi
  printf '%s' "$default"
  return 0
}

repo_fetch_prune() {
  git fetch --prune "$GIT_WS_REMOTE"
  return $?
}

fast_forward_local_branch() {
  local local_branch="$1"
  local remote_name="$2"
  local current_branch

  current_branch="$(git branch --show-current 2>/dev/null || true)"
  if [[ "$local_branch" == "$current_branch" ]]; then
    if ! git merge --ff-only "${GIT_WS_REMOTE}/${remote_name}"; then
      log_warn "could not fast-forward checked-out branch '${local_branch}'"
      return 1
    fi
    return 0
  fi

  if ! git fetch "$GIT_WS_REMOTE" "refs/heads/${remote_name}:refs/heads/${local_branch}"; then
    log_warn "could not fast-forward local branch '${local_branch}' (diverged or fetch error)"
    return 1
  fi
  return 0
}

repo_sync_tracked_locals() {
  local local_branch upstream remote_name

  while IFS= read -r local_branch; do
    [[ -z "$local_branch" ]] && continue
    upstream="$(git rev-parse --abbrev-ref "${local_branch}@{upstream}" 2>/dev/null)" || continue
    [[ "$upstream" == "${GIT_WS_REMOTE}/"* ]] || continue
    remote_name="${upstream#"${GIT_WS_REMOTE}"/}"
    fast_forward_local_branch "$local_branch" "$remote_name" || true
  done < <(git for-each-ref --format='%(refname:short)' refs/heads/)
  return 0
}

repo_is_gone_local_branch() {
  local branch_name="$1"
  local upstream remote_ref

  upstream="$(git for-each-ref --format='%(upstream:short)' "refs/heads/${branch_name}" 2>/dev/null)"
  [[ -n "$upstream" ]] || return 1
  [[ "$upstream" == "${GIT_WS_REMOTE}/"* ]] || return 1
  remote_ref="refs/remotes/${upstream}"
  if git show-ref --verify --quiet "$remote_ref"; then
    return 1
  fi
  return 0
}

# If the current branch's upstream is gone, checkout and fast-forward the default
# branch so that branch can be included in the delete prompt.
repo_leave_gone_current_branch() {
  local current_branch

  current_branch="$(git branch --show-current 2>/dev/null || true)"
  [[ -n "$current_branch" ]] || return 0
  if ! repo_is_gone_local_branch "$current_branch"; then
    return 0
  fi

  log_info "current branch '${current_branch}' has gone upstream; checking out default"
  repo_checkout_and_update_default
  return $?
}

# Prints gone local branch names in the current repo (one per line), excluding current branch.
repo_list_gone_local_branches() {
  local current_branch branch_name

  current_branch="$(git branch --show-current 2>/dev/null || true)"

  while IFS= read -r branch_name; do
    [[ -z "$branch_name" ]] && continue
    if ! repo_is_gone_local_branch "$branch_name"; then
      continue
    fi
    if [[ "$branch_name" == "$current_branch" ]]; then
      log_warn "skipping delete of current branch '${branch_name}' (gone upstream)"
      continue
    fi
    printf '%s\n' "$branch_name"
  done < <(git for-each-ref --format='%(refname:short)' refs/heads/)
  return 0
}

# Prints repo_path|repo_basename|branch_name for each deletable gone branch workspace-wide.
workspace_collect_gone_branches() {
  local repo repo_base branch_name
  local repos=()

  mapfile -t repos < <(discover_git_repos)

  for repo in "${repos[@]}"; do
    [[ -z "$repo" ]] && continue
    repo_base="$(basename "$repo")"
    while IFS= read -r branch_name; do
      [[ -z "$branch_name" ]] && continue
      printf '%s|%s|%s\n' "$repo" "$repo_base" "$branch_name"
    done < <(
      cd "$repo" || exit 1
      repo_list_gone_local_branches
    )
  done
  return 0
}

# Returns 0 when the user confirms batch deletion; 1 to skip.
confirm_force_delete_gone_branches() {
  local count=$#
  local line repo_base branch_name reply

  if [[ "$count" -eq 0 ]]; then
    return 1
  fi

  printf '\nThe following local branches have gone upstreams and will be force-deleted:\n\n'
  for line in "$@"; do
    repo_base="${line#*|}"
    repo_base="${repo_base%%|*}"
    branch_name="${line##*|}"
    printf '  [%s] %s\n' "$repo_base" "$branch_name"
  done
  printf '\n'

  if [[ ! -t 0 ]]; then
    log_warn "stdin is not a TTY; skipping force-delete of ${count} branch(es)"
    log_warn "run interactively to confirm deletion"
    return 1
  fi

  printf 'Delete %d branch(es)? [y/N] ' "$count"
  read -r reply
  case "${reply,,}" in
    y | yes)
      return 0
      ;;
    *)
      log_info "skipped deleting ${count} branch(es)"
      return 1
      ;;
  esac
}

workspace_force_prune_gone_locals() {
  local line repo_path repo_base branch_name

  for line in "$@"; do
    repo_path="${line%%|*}"
    repo_base="${line#*|}"
    repo_base="${repo_base%%|*}"
    branch_name="${line##*|}"

    if (
      cd "$repo_path" || exit 1
      if ! git branch -D "$branch_name"; then
        log_warn "could not force-delete branch '${branch_name}' in ${repo_base}"
        exit 1
      fi
    ); then
      log_info "deleted [${repo_base}] ${branch_name}"
    else
      mark_failed
    fi
  done

  return "$GIT_WS_FAILED"
}

workspace_prune_gone_with_confirm() {
  local candidates=()

  mapfile -t candidates < <(workspace_collect_gone_branches)

  if [[ "${#candidates[@]}" -eq 0 ]]; then
    return 0
  fi

  if confirm_force_delete_gone_branches "${candidates[@]}"; then
    workspace_force_prune_gone_locals "${candidates[@]}"
    return $?
  fi

  return 0
}

repo_fetch_all_remote_branches() {
  local ref_short name local_upstream

  while IFS= read -r ref_short; do
    [[ -z "$ref_short" ]] && continue
    [[ "$ref_short" == "${GIT_WS_REMOTE}/HEAD" ]] && continue
    [[ "$ref_short" == "${GIT_WS_REMOTE}" ]] && continue
    name="${ref_short#"${GIT_WS_REMOTE}"/}"
    [[ -z "$name" ]] && continue

    if git show-ref --verify --quiet "refs/heads/${name}"; then
      local_upstream="$(git rev-parse --abbrev-ref "${name}@{upstream}" 2>/dev/null || true)"
      if [[ "$local_upstream" == "${GIT_WS_REMOTE}/${name}" ]]; then
        fast_forward_local_branch "$name" "$name" || true
      elif [[ -z "$local_upstream" ]]; then
        log_warn "local branch '${name}' exists without upstream '${GIT_WS_REMOTE}/${name}'; skipping"
      else
        log_warn "local branch '${name}' tracks '${local_upstream}'; skipping"
      fi
    else
      if ! git branch --track "$name" "${GIT_WS_REMOTE}/${name}"; then
        log_warn "could not create tracking branch '${name}'"
      fi
    fi
  done < <(git for-each-ref --format='%(refname:short)' "refs/remotes/${GIT_WS_REMOTE}")
  return 0
}

repo_checkout_and_update_default() {
  local default

  default="$(resolve_default_branch)"
  if ! git checkout "$default" 2>/dev/null; then
    if ! git show-ref --verify --quiet "refs/remotes/${GIT_WS_REMOTE}/${default}"; then
      log_err "could not checkout '${default}' (missing locally and on ${GIT_WS_REMOTE})"
      return 1
    fi
    if ! git checkout -b "$default" "${GIT_WS_REMOTE}/${default}"; then
      log_err "could not create local '${default}' from ${GIT_WS_REMOTE}/${default}"
      return 1
    fi
  fi
  if ! git merge --ff-only "${GIT_WS_REMOTE}/${default}"; then
    log_err "could not fast-forward '${default}' to ${GIT_WS_REMOTE}/${default}"
    return 1
  fi
  return 0
}

run_for_each_repo() {
  local callback="$1"
  local repo
  local repos=()
  local repo_count=0

  mapfile -t repos < <(discover_git_repos)
  repo_count="${#repos[@]}"

  if [[ "$repo_count" -eq 0 ]]; then
    log_err "no git repositories found under ${WORKSPACE_ROOT}"
    log_err "set WORKSPACE_ROOT to the parent folder that contains your clones"
    exit 1
  fi

  log_info "workspace: ${WORKSPACE_ROOT} (${repo_count} repositories)"

  for repo in "${repos[@]}"; do
    [[ -z "$repo" ]] && continue
    repo_header "$repo"
    if (
      cd "$repo" || exit 1
      "$callback"
    ); then
      :
    else
      mark_failed
      log_err "[$(basename "$repo")] failed"
    fi
  done

  return "$GIT_WS_FAILED"
}

print_workspace_help() {
  local script_name="$1"
  cat <<EOF
Usage: $(basename "$script_name") [options]

Options:
  -h, --help    Show this help

Environment:
  WORKSPACE_ROOT   Parent directory containing sibling git clones
                   (default: parent of the .github clone containing these scripts)
  GIT_WS_REMOTE    Remote name (default: origin)
EOF
  return 0
}
