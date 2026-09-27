# shellcheck shell=bash
# Shared helpers for multi-repo git workspace maintenance.
# Source this file; do not execute directly.

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  printf 'error: source this file; do not execute directly\n' >&2
  exit 1
fi

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

# Populates the array named by $1 from stdout of command "$2" and later args.
# Returns the command's exit status (or 1 if mapfile fails). Unlike
# mapfile -t arr < <(cmd), this does not ignore a non-zero exit from cmd.
mapfile_from_cmd() {
  local -n _target=$1
  shift
  local _tmp _status=0

  _tmp="$(mktemp "${TMPDIR:-/tmp}/git-ws-mapfile.XXXXXX")" || return 1
  "$@" >"$_tmp" || _status=$?
  mapfile -t _target <"$_tmp" || _status=1
  rm -f "$_tmp"
  return "$_status"
}

workspace_root_resolved() {
  local status=0

  (cd "$WORKSPACE_ROOT" && pwd -P) || status=$?
  return "$status"
}

home_dir_resolved() {
  local status=0

  if [[ -z "${HOME:-}" ]]; then
    return 1
  fi

  (cd "${HOME}" && pwd -P) || status=$?
  return "$status"
}

is_overly_broad_workspace_root() {
  local resolved="$1"
  local home_resolved

  if [[ "$resolved" == "/" ]]; then
    return 0
  fi

  if home_resolved="$(home_dir_resolved)" && [[ "$resolved" == "$home_resolved" ]]; then
    return 0
  fi
  return 1
}

has_documented_sibling_layout() {
  local meta="${WORKSPACE_ROOT}/.github"

  if is_git_repo "$meta" && [[ -f "${meta}/scripts/git-workspace-lib.sh" ]]; then
    return 0
  fi
  return 1
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

  if ! resolved="$(workspace_root_resolved)"; then
    log_err "failed to resolve WORKSPACE_ROOT: ${WORKSPACE_ROOT}"
    exit 1
  fi
  if is_overly_broad_workspace_root "$resolved"; then
    if [[ "${GIT_WS_ALLOW_BROAD_ROOT:-}" != "1" ]]; then
      log_err "WORKSPACE_ROOT is too broad (${resolved})"
      log_err "these scripts affect every git clone directly under WORKSPACE_ROOT"
      log_err "set GIT_WS_ALLOW_BROAD_ROOT=1 only when you intend that scope"
      exit 1
    fi
    log_warn "WORKSPACE_ROOT is broad (${resolved}); proceeding because GIT_WS_ALLOW_BROAD_ROOT=1"
  elif ! has_documented_sibling_layout; then
    log_warn "WORKSPACE_ROOT does not match the documented sibling layout (.github, registry, cli, webapp, …)"
    log_warn "confirm WORKSPACE_ROOT points at the agents-repo parent folder, not a higher directory"
  fi

  return 0
}

require_safe_workspace_for_destructive_ops() {
  local resolved

  if ! resolved="$(workspace_root_resolved)"; then
    log_err "failed to resolve WORKSPACE_ROOT: ${WORKSPACE_ROOT}"
    return 1
  fi
  if is_overly_broad_workspace_root "$resolved" && [[ "${GIT_WS_ALLOW_BROAD_ROOT:-}" != "1" ]]; then
    log_warn "skipping gone-branch prune: WORKSPACE_ROOT is too broad (${resolved})"
    log_warn "set GIT_WS_ALLOW_BROAD_ROOT=1 only when you intend workspace-wide destructive maintenance"
    return 1
  fi

  if ! has_documented_sibling_layout && [[ "${GIT_WS_ALLOW_BROAD_ROOT:-}" != "1" ]]; then
    log_warn "skipping gone-branch prune: WORKSPACE_ROOT is not the documented agents-repo sibling folder"
    log_warn "expected ${WORKSPACE_ROOT}/.github/scripts/git-workspace-lib.sh"
    log_warn "set GIT_WS_ALLOW_BROAD_ROOT=1 to override (you will prune every direct-child git clone)"
    return 1
  fi

  return 0
}

require_git() {
  if ((BASH_VERSINFO[0] < 4)) \
    || ((BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3)); then
    log_err "bash 4.3+ required (found ${BASH_VERSION}); install a newer bash on macOS (e.g. Homebrew)"
    exit 1
  fi
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
  local null_sort_ok=0

  if printf 'b\0a' | LC_ALL=C sort -z >/dev/null 2>&1; then
    null_sort_ok=1
  fi

  if [[ "$null_sort_ok" -eq 1 ]]; then
    while IFS= read -r -d '' dir; do
      if is_git_repo "$dir"; then
        printf '%s\n' "$dir"
      fi
    done < <(
      LC_ALL=C find "$WORKSPACE_ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | LC_ALL=C sort -z
    )
  else
    while IFS= read -r dir; do
      [[ -z "$dir" ]] && continue
      if is_git_repo "$dir"; then
        printf '%s\n' "$dir"
      fi
    done < <(
      LC_ALL=C find "$WORKSPACE_ROOT" -mindepth 1 -maxdepth 1 -type d | LC_ALL=C sort
    )
  fi
  return 0
}

repo_header() {
  local repo_path="$1"
  log_info "[$(basename "$repo_path")] $repo_path"
  return 0
}

resolve_default_branch() {
  local default=""
  local ref=""
  ref="$(git symbolic-ref --short "refs/remotes/${GIT_WS_REMOTE}/HEAD" 2>/dev/null || true)"
  if [[ -n "$ref" ]]; then
    default="${ref#${GIT_WS_REMOTE}/}"
  fi
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

  log_info "current branch '${current_branch}' tracks a gone upstream; checking out default"
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

_repo_gone_branches_lines() {
  local repo_path="$1"

  (
    cd "$repo_path" || exit 1
    repo_list_gone_local_branches
  )
}

# Prints repo_path<TAB>repo_basename<TAB>branch_name for each deletable gone branch
# workspace-wide (tab is not valid in git ref names).
workspace_collect_gone_branches() {
  local repo repo_base branch_name
  local repos=()
  local branches=()

  if ! mapfile_from_cmd repos discover_git_repos; then
    log_err "could not discover git repositories under ${WORKSPACE_ROOT}"
    mark_failed
    return 1
  fi

  for repo in "${repos[@]}"; do
    [[ -z "$repo" ]] && continue
    repo_base="$(basename "$repo")"
    branches=()
    if ! mapfile_from_cmd branches _repo_gone_branches_lines "$repo"; then
      log_err "could not collect gone branches in ${repo_base}"
      mark_failed
      continue
    fi
    for branch_name in "${branches[@]}"; do
      [[ -z "$branch_name" ]] && continue
      printf '%s\t%s\t%s\n' "$repo" "$repo_base" "$branch_name"
    done
  done
  return "$GIT_WS_FAILED"
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
    IFS=$'\t' read -r _repo_path repo_base branch_name <<<"$line"
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
    IFS=$'\t' read -r repo_path repo_base branch_name <<<"$line"

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
  local collect_status=0
  local prune_status=0

  if ! require_safe_workspace_for_destructive_ops; then
    return 0
  fi

  if ! mapfile_from_cmd candidates workspace_collect_gone_branches; then
    collect_status=1
  fi

  if [[ "${#candidates[@]}" -eq 0 ]]; then
    return "$collect_status"
  fi

  if confirm_force_delete_gone_branches "${candidates[@]}"; then
    workspace_force_prune_gone_locals "${candidates[@]}" || prune_status=$?
  fi

  [[ "$collect_status" -eq 0 && "$prune_status" -eq 0 ]]
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
    if git show-ref --verify --quiet "refs/heads/${default}"; then
      log_err "could not checkout '${default}' (local branch exists; check worktree or conflicts)"
      return 1
    fi
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

  if ! mapfile_from_cmd repos discover_git_repos; then
    log_err "could not discover git repositories under ${WORKSPACE_ROOT}"
    exit 1
  fi
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
  GIT_WS_REMOTE              Remote name (default: origin)
  GIT_WS_ALLOW_BROAD_ROOT    Set to 1 to allow WORKSPACE_ROOT=/, \$HOME, or
                             non-documented layouts for destructive maintenance
EOF
  return 0
}
