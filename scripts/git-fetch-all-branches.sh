#!/usr/bin/env bash
# Create or fast-forward local branches for every origin branch.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=git-workspace-lib.sh
source "${SCRIPT_DIR}/git-workspace-lib.sh"

repo_materialize_remotes() {
  if ! repo_fetch_prune; then
    return 1
  fi
  repo_fetch_all_remote_branches
}

main() {
  case "${1:-}" in
    -h | --help)
      print_workspace_help "$0"
      exit 0
      ;;
  esac

  require_git
  run_for_each_repo repo_materialize_remotes
  exit $?
}

main "$@"
