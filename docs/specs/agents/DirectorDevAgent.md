# DirectorDev Agent Spec

## Overview

The DirectorDev agent (Agent 0) is the always-running orchestrator daemon that
coordinates the autonomous development and self-improvement of ReviewCat. It
manages role agents, worktrees, GitHub Issues/PRs, and the circular
self-improvement loop.

It is implemented as a bash heartbeat daemon (`dev/harness/director.sh`) that
coordinates Copilot CLI role agents, manages parallel git worktrees, and uses
the GitHub MCP Server for issue/PR coordination.

> **See also:** [PLAN.md](../../../PLAN.md) §5 for heartbeat architecture,
> [DIRECTOR_DEV_WORKFLOW.md](../../DIRECTOR_DEV_WORKFLOW.md) for workflow details.

## Requirements

1. Must operate spec-first: implementation tasks must reference a spec file.
2. Must coordinate role agents in a predictable order.
3. Must run build/test after implementation as a validation gate.
4. Must record a development audit bundle for every cycle.
5. Must manage parallel git worktrees for concurrent agent execution.
6. Must use GitHub MCP Server for issue/PR coordination.
7. Must implement the circular self-review loop (review → issues → fix → PR → merge → review).
8. Must support a configurable heartbeat interval and MAX_WORKERS limit.

## Interfaces

- Entry: `dev/harness/director.sh` (heartbeat daemon)
- Single task: `dev/harness/run-cycle.sh <task> <branch>`
- Worktree management: `dev/harness/worktree.sh create|teardown|list`
- Self-review: `dev/harness/review-self.sh`
- Worker monitoring: `dev/harness/monitor-workers.sh`
- Artifact output: `dev/audits/<audit_id>/`

Role agents are defined under `.github/agents/` and `dev/agents/` as markdown
prompt files, invoked via `copilot -p @dev/agents/<role>.md "..."`.

## Heartbeat Loop

The Director runs as a persistent bash daemon with the following loop:

1. **Wake** — Heartbeat timer fires.
2. **Scan** — List open GitHub Issues labeled `agent-task` via GitHub MCP.
3. **Check PRD** — Read `dev/plans/prd.json` for spec-driven work.
4. **Claim** — For each unclaimed issue, add `agent-claimed` label.
5. **Dispatch** — Create worktree, spawn agent to work on the issue.
6. **Monitor** — Check active worktrees for completion.
7. **PR** — Completed agents create PRs via GitHub MCP.
8. **Review** — Code-review agent reviews PRs via GitHub MCP.
9. **Validate** — Run `./scripts/build.sh && ./scripts/test.sh`.
10. **Merge** — If validation passes, merge PR and close linked issue.
11. **Teardown** — Remove completed worktrees.
12. **Self-review** — When idle, review own code and create new issues.
13. **Sleep** — Wait for next heartbeat interval.

## Acceptance criteria

- Given open GitHub Issues labeled `agent-task`:
  - Director creates worktrees and dispatches agents.
  - Agents produce code changes, tests, and PRs.
  - Build/test validation passes before merge.
  - PRs are merged and linked issues are closed.
  - Prompt ledger records all interactions.
- When idle (no open issues or PRD tasks):
  - Director runs self-review via `dev/harness/review-self.sh`.
  - Self-review creates new GitHub Issues for critical/high findings.
  - These issues feed the next heartbeat cycle.
- The circular loop runs indefinitely while the daemon is active.

## Test cases

- Run DirectorDev in replay mode (no Copilot calls) using fixtures.
- Verify worktree creation and teardown lifecycle.
- Verify issue claiming prevents duplicate work.
- Verify self-review triggers when no other work is available.

## Edge cases

- Spec incomplete or ambiguous.
- A role agent produces conflicting recommendations.
- Worktree creation fails (branch collision, disk space).
- GitHub MCP Server unavailable (fallback to `gh` CLI).
- All worker slots occupied (defer new tasks).
- Director crashes mid-cycle (PID file + graceful restart).

## Non-functional constraints

- Scope control: DirectorDev must refuse to expand scope beyond spec unless
  explicitly authorized.
- Safety: no network actions without opt-in; dry-run default.
- Worktree isolation: agents cannot modify the main worktree directly.
- PR-gated merges: all changes go through PRs, never direct main commits.
- PID file for single-instance enforcement.
- Graceful shutdown via SIGTERM/SIGINT.
