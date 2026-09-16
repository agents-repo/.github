#!/usr/bin/env bash
# Start cursor agent worker with one --worker-dir per sibling clone under WORKSPACE_ROOT.
# The .github clone is listed first (assignment identity for Cursor).

set -euo pipefail

if [[ "${BASH_VERSINFO[0]}" -lt 4 ]] ||
  [[ "${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -lt 3 ]]; then
  echo "cursor-agent-worker-start.sh requires Bash 4.3+ (nameref); found ${BASH_VERSION}" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=git-workspace-lib.sh
source "${SCRIPT_DIR}/git-workspace-lib.sh"

CURSOR_AGENT_WORKER_NAME="${CURSOR_AGENT_WORKER_NAME:-}"
CURSOR_AGENT_WORKER_VERBOSE="${CURSOR_AGENT_WORKER_VERBOSE:-0}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [options] [--] [cursor agent worker options...]

Start \`cursor agent worker start\` with --worker-dir for each git clone under
WORKSPACE_ROOT. The .github directory is passed first when present.

Options:
  -h, --help       Show this help
  -n, --dry-run    Print the command without running it
  --name NAME      Worker display name (or set CURSOR_AGENT_WORKER_NAME)

Environment:
  WORKSPACE_ROOT              Parent folder with sibling clones (see git-workspace-lib.sh)
  CURSOR_AGENT_WORKER_NAME    Default for --name
  CURSOR_AGENT_WORKER_VERBOSE  Set to 1 to pass --verbose to cursor agent worker start

Any arguments after -- are forwarded to \`cursor agent worker\` before \`start\`
(for example --pool or --management-addr). Use CURSOR_AGENT_WORKER_VERBOSE=1 for
\`start --verbose\`.

See docs/cursor-agent-worker.md for Linux startup (systemd user service).
EOF
}

require_cursor() {
  if ! command -v cursor >/dev/null 2>&1; then
    log_err "cursor not found on PATH (install Cursor and ensure cursor agent is available)"
    exit 1
  fi
  if ! cursor agent worker start --help >/dev/null 2>&1; then
    log_err "cursor agent worker is not available in this cursor CLI build"
    exit 1
  fi
}

# Prints worker directory paths: .github first, then other repos (sorted, no duplicates).
resolve_worker_directories() {
  local repos=()
  local repo github_dir=""

  mapfile -t repos < <(discover_git_repos)

  if [[ "${#repos[@]}" -eq 0 ]]; then
    log_err "no git repositories found under ${WORKSPACE_ROOT}"
    exit 1
  fi

  for repo in "${repos[@]}"; do
    if [[ "$(basename "$repo")" == ".github" ]]; then
      github_dir="$repo"
      break
    fi
  done

  if [[ -n "$github_dir" ]]; then
    printf '%s\n' "$github_dir"
  fi

  for repo in "${repos[@]}"; do
    [[ -z "$repo" ]] && continue
    if [[ -n "$github_dir" && "$repo" == "$github_dir" ]]; then
      continue
    fi
    printf '%s\n' "$repo"
  done
}

# cursor agent worker: worker-level flags before "start"; only start subcommand flags after.
assemble_worker_start_cmd() {
  local out_ref_name=$1
  shift
  local -n out_ref=$out_ref_name
  local -a worker_dirs=()
  local dir

  mapfile -t worker_dirs < <(resolve_worker_directories)

  out_ref=(cursor agent worker)

  for dir in "${worker_dirs[@]}"; do
    out_ref+=(--worker-dir "$dir")
  done

  if [[ -n "$CURSOR_AGENT_WORKER_NAME" ]]; then
    out_ref+=(--name "$CURSOR_AGENT_WORKER_NAME")
  fi

  if [[ "$#" -gt 0 ]]; then
    out_ref+=("$@")
  fi

  out_ref+=(start)

  if [[ "$CURSOR_AGENT_WORKER_VERBOSE" == "1" ]]; then
    out_ref+=(--verbose)
  fi
}

main() {
  local dry_run=0
  local forward_args=()
  local unexpected_arg

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h | --help)
        usage
        return 0
        ;;
      -n | --dry-run)
        dry_run=1
        shift
        ;;
      --name)
        if [[ $# -lt 2 ]]; then
          log_err "--name requires a value"
          exit 1
        fi
        CURSOR_AGENT_WORKER_NAME="$2"
        shift 2
        ;;
      --)
        shift
        forward_args=("$@")
        break
        ;;
      *)
        unexpected_arg=$1
        log_err "unexpected argument: ${unexpected_arg} (use -- before cursor agent worker options)"
        exit 1
        ;;
    esac
  done

  require_git
  require_cursor

  log_info "workspace: ${WORKSPACE_ROOT}"

  local -a cmd=()
  local i

  assemble_worker_start_cmd cmd "${forward_args[@]}"

  for ((i = 0; i < ${#cmd[@]}; i++)); do
    if [[ "${cmd[$i]}" == --worker-dir ]]; then
      i=$((i + 1))
      if [[ $i -lt ${#cmd[@]} ]]; then
        log_info "worker-dir: ${cmd[$i]}"
      fi
    fi
  done

  if [[ "$dry_run" -eq 1 ]]; then
    printf '%q ' "${cmd[@]}"
    printf '\n'
    return 0
  fi

  exec "${cmd[@]}"
}

main "$@"
