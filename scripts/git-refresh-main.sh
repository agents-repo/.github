#!/usr/bin/env bash
# Prune gone locals, sync tracked branches, checkout default branch, fast-forward from origin.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=git-workspace-lib.sh
source "${SCRIPT_DIR}/git-workspace-lib.sh"

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
  run_for_each_repo repo_refresh
  return $?
}

main "$@"
exit $?
