#!/usr/bin/env bash
# For each branch on GIT_WS_REMOTE (default: origin): create a tracking local, or
# fast-forward when that local already tracks the matching remote branch; skip
# same-named locals with a missing or different upstream.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=git-workspace-lib.sh
source "${SCRIPT_DIR}/git-workspace-lib.sh"

# Invoked indirectly via run_for_each_repo callback name.
# shellcheck disable=SC2317
repo_materialize_remotes() {
  if ! repo_fetch_prune; then
    return 1
  fi
  repo_fetch_all_remote_branches
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
  run_for_each_repo repo_materialize_remotes
  return $?
}

main "$@"
exit $?
