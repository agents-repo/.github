#!/usr/bin/env bash
# Sync local branches that track origin (fast-forward only). Does not create new locals.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=git-workspace-lib.sh
source "${SCRIPT_DIR}/git-workspace-lib.sh"

repo_sync_all() {
  if ! repo_fetch_prune; then
    return 1
  fi
  repo_sync_tracked_locals
}

main() {
  case "${1:-}" in
    -h | --help)
      print_workspace_help "$0"
      exit 0
      ;;
  esac

  require_git
  run_for_each_repo repo_sync_all
  exit $?
}

main "$@"
