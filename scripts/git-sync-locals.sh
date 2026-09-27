#!/usr/bin/env bash
# Fast-forward locals whose upstream is on GIT_WS_REMOTE (default: origin). Does not create new locals.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=git-workspace-lib.sh
source "${SCRIPT_DIR}/git-workspace-lib.sh"

# Invoked indirectly via run_for_each_repo callback name.
# shellcheck disable=SC2317
repo_sync_all() {
  if ! repo_fetch_prune; then
    return 1
  fi
  repo_sync_tracked_locals
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
        local unknown_arg="$1"
        log_err "unknown argument: ${unknown_arg}"
        return 1
      fi
      ;;
  esac

  require_git
  run_for_each_repo repo_sync_all
  return $?
}

main "$@"
exit $?
