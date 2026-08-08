#!/usr/bin/env bash
# Create or fast-forward local branches for every origin branch.

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
