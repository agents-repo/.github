#!/usr/bin/env bash
# Delete local branches whose upstream was removed on the remote (safe git branch -d).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=git-workspace-lib.sh
source "${SCRIPT_DIR}/git-workspace-lib.sh"

# Invoked indirectly via run_for_each_repo callback name.
# shellcheck disable=SC2317
repo_prune_all() {
  if ! repo_fetch_prune; then
    return 1
  fi
  repo_prune_gone_locals
  return 0
}

main() {
  case "${1:-}" in
    -h | --help)
      print_workspace_help "$0"
      return 0
      ;;
    *)
      if [[ -n "${1:-}" ]]; then
        log_err "unknown argument: $1"
        return 1
      fi
      ;;
  esac

  require_git
  run_for_each_repo repo_prune_all
  return $?
}

main "$@"
exit $?
