---
name: maiconfz--github-issue-implementation-planner--issue-implementation-planning
description: >-
  Route GitHub issue planning to interactive or automatic mode. Use with one or
  many issue references. Planning only unless execution is explicitly requested.
---
# Overview

Primary **planning-only** entry. Resolves `planning-mode` and delegates to
exactly one mode flow. Does not intake issues or draft plans itself.

```text
resolve issue-references → resolve mode → invoke mode flow → handoff
```

## Steps

1. **References** — If `issue-references` is missing and `issue-reference` is
   present, treat it as `issue-references`. If still empty, ask once and stop.

2. **Mode** — If `planning-mode` is not `interactive` or `automatic`, ask which
   to use. Do not default silently.

3. **Delegate** — Invoke `interactive-issue-implementation-planning` or
   `automatic-issue-implementation-planning` with the same inputs except omit
   redundant mode prompting inside the child flow.

4. **Handoff** — Present outputs from the selected mode flow. State that
   implementation requires an explicit user request.

When the host IDE provides a planning-only mode, use it. MUST NOT start code
implementation unless the user explicitly requests execution.

## Error Handling

- **User points at this flow but already chose a mode:** They may call a mode
  flow directly instead.
- **Mode flow returns partial plan after escalation:** Pass through outputs
  without restarting intake.

## Interaction Contract

**Input:** `issue-references`, optional `repository`, optional `planning-mode`,
optional `pr-grouping`, optional `execution-topology`, optional
`user-clarifications`.

**Output:** `refined-implementation-plan`, `open-questions`, `assumption-log`.

## Declared capabilities

### Inputs

- `issue-references` (string): One or more issue numbers or full GitHub issue URLs.
- `repository` (string): Optional target repository as owner/name when not inferable.
- `planning-mode` (string): interactive or automatic; ask which to use when missing.
- `pr-grouping` (string): Optional override per-issue, related, or single.
- `execution-topology` (string): Optional override sequential or parallel.
- `user-clarifications` (string): Optional user answers accumulated across clarification loops.

### Outputs

- `refined-implementation-plan` (string): Final markdown implementation plan after refinement.
- `open-questions` (string): Markdown list of remaining questions after planning.
- `assumption-log` (string): Labeled assumptions from automatic mode; empty after interactive.

<!-- agents-repo package version: 1.0.0 -->
