# Local Cursor agent worker (multi-repo workspace)

Use this when you run a **private agent worker** on your own Linux machine so
Cloud Agents and Automations can execute on your sibling-clone workspace (the
same layout as [local-git-workspace.md](local-git-workspace.md) and
[agents-repo.code-workspace](../agents-repo.code-workspace)).

The worker CLI exposes multiple folders via repeatable `--worker-dir` flags.
[`scripts/cursor-agent-worker-start.sh`](../scripts/cursor-agent-worker-start.sh)
discovers git clones under `WORKSPACE_ROOT`, puts **`.github` first** (assignment
identity), and runs `cursor agent worker start`.

## Requirements

- [Cursor](https://cursor.com) installed with the `cursor` CLI on `PATH`
- `cursor agent login` completed once for the account that should own the worker
- Bash 4.3+ and sibling clones under one `WORKSPACE_ROOT` (see
  [local-git-workspace.md](local-git-workspace.md))

## Manual start

From the workspace root (recommended):

```bash
cd ~/dev/projects/agents-repo
./.github/scripts/cursor-agent-worker-start.sh
```

Override the workspace root when clones live elsewhere:

```bash
export WORKSPACE_ROOT=/path/to/agents-repo
/path/to/agents-repo/.github/scripts/cursor-agent-worker-start.sh
```

Preview the command without connecting:

```bash
./.github/scripts/cursor-agent-worker-start.sh --dry-run
```

Optional worker display name and verbose logs:

```bash
export CURSOR_AGENT_WORKER_NAME=agents-repo-linux
export CURSOR_AGENT_WORKER_VERBOSE=1
./.github/scripts/cursor-agent-worker-start.sh
```

Forward extra **worker-level** flags to `cursor agent worker` (after `--`; placed
before `start`):

```bash
./.github/scripts/cursor-agent-worker-start.sh -- --management-addr 127.0.0.1:8080
```

Leave the process running in a terminal or use the systemd setup below.

## Linux startup (systemd user service)

Use a **user** unit so the worker runs as your login user (same credentials as
`cursor agent login`).

### 1. Authenticate once

```bash
cursor agent login
cursor agent status
```

### 2. Install the unit file

Copy the example unit and edit paths to match your machine:

```bash
mkdir -p ~/.config/systemd/user
cp ~/dev/projects/agents-repo/.github/scripts/cursor-agent-worker.service.example \
  ~/.config/systemd/user/cursor-agent-worker.service
${EDITOR:-nano} ~/.config/systemd/user/cursor-agent-worker.service
```

Set at minimum:

- `Environment=WORKSPACE_ROOT=...` — parent folder containing `.github`, `cli`, etc.
- `ExecStart=.../cursor-agent-worker-start.sh` — absolute path to this script
- `Environment=PATH=...` — must include the directory that contains the `cursor`
  binary (often `/usr/bin`)

Optional:

- `Environment=CURSOR_AGENT_WORKER_NAME=...`
- `Environment=CURSOR_AGENT_WORKER_VERBOSE=1`

### 3. Enable and start

```bash
systemctl --user daemon-reload
systemctl --user enable --now cursor-agent-worker.service
systemctl --user status cursor-agent-worker.service
```

Logs:

```bash
journalctl --user -u cursor-agent-worker.service -f
```

### 4. Start at boot (optional)

User services normally stop when you log out. To keep the worker running after
logout and across reboots (without an interactive session):

```bash
loginctl enable-linger "$USER"
```

Verify:

```bash
loginctl show-user "$USER" -p Linger
```

### Troubleshooting

| Symptom | Check |
| --- | --- |
| `cursor not found on PATH` | Fix `PATH` in the unit file; run `which cursor`. |
| Worker exits immediately | `journalctl --user -u cursor-agent-worker.service -n 50`; re-run `cursor agent login`. |
| Wrong repos exposed | `WORKSPACE_ROOT` must be the **parent** of clones, not a single repo. |
| Duplicate workers | Only one `cursor agent worker` per machine/display name; stop old units or terminals first. |

## Related docs

- [Cursor Cloud environments](cursor-cloud.md) — hosted multi-repo bootstrap
- [Local multi-repo Git workspace](local-git-workspace.md) — `WORKSPACE_ROOT` layout
