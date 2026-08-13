#!/usr/bin/env bash
# Fetch --prune, leave gone current branch, then force-delete gone locals (batch confirmation).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=git-workspace-lib.sh
source "${SCRIPT_DIR}/git-workspace-lib.sh"

main() {
  local status=0

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
  run_for_each_repo repo_fetch_prune || status=$?
  run_for_each_repo repo_leave_gone_current_branch || status=$?
  workspace_prune_gone_with_confirm || status=$?
  return "$status"
}

main "$@"
exit $?
