# Architecture Overview

ReviewCat is a code review tool that aims to make AI-assisted reviews:

- **repeatable** (stable prompts + structured outputs)
- **auditable** (every model invocation recorded in a prompt ledger)
- **actionable** (findings → issues/tasks → fixes)
- **safe by default** (dry-run, explicit opt-in for mutations)

At a high level, it’s a **two-part system**:

1. **Runtime app** (`app/`): the end-user CLI/daemon/UI.
2. **Dev harness** (`dev/`): the self-improving development loop (Director + workers).

The repo’s “meta loop” is:

> **bootstrap → dev → app → dev → app → …**

## Problem statement

Developers want fast, repeatable, high-signal review feedback before pushing a PR.
Copilot CLI can help, but ad-hoc prompts lead to inconsistent results and make it
hard to compare review quality over time.

ReviewCat turns Copilot CLI into an opinionated workflow that produces:

- structured persona findings
- a unified review
- an actionable change plan
- an audit trail (prompt ledger + artifacts)

## Goals

Runtime app goals:

- Provide a high-quality, repeatable review experience on local diffs and PRs.
- Produce artifacts that are readable (Markdown) and machine-parseable (JSON).
- Make it easy to go from findings to an actionable plan.

Dev harness goals:

- Enable circular self-improvement (review → issues → fixes → PRs → repeat).
- Use GitHub (issues/PRs/labels/comments) as the coordination layer.

## Future-goals

- Eliminating human oversight entirely (humans can steer or stop the system).
- Auto-merging changes without validation.
- Support external cloud services beyond GitHub.

## Autonomy model (human interaction)

Default behavior is **zero-touch autonomous**: daemons advance loops without
interactive prompts.

Humans can still interact in three supported ways:

1. **Steering (optional):** create issues, comments, and labels to guide scope.
2. **Blocked escalation:** agents apply `agent-blocked` + a structured context comment.
3. **Stop/pause (operational):** stop the Director (or its container) to halt work.

## Runtime app (end-user)

The runtime app reviews local diffs or GitHub PRs using persona prompts, then
deduplicates and prioritizes findings into a unified output. When enabled, it
can create issues/PRs/comments via GitHub tooling.

Key docs:

- Usage + artifacts: [`docs/specs/app/USAGE.md`](specs/app/USAGE.md)
- App configuration (planned): [`docs/specs/app/CONFIGURATION.md`](specs/app/CONFIGURATION.md)
- Runtime specs: `docs/specs/app/`

## Dev harness (self-building)

The dev harness is the repo’s autonomous development coordinator:

- a **Director** daemon (Agent 0) runs a heartbeat loop
- it claims GitHub issues, creates isolated git worktrees, dispatches workers
- changes are validated (build + tests) and integrated via PRs

Key docs:

- Director workflow: [`docs/specs/dev/DIRECTOR_DEV_WORKFLOW.md`](specs/dev/DIRECTOR_DEV_WORKFLOW.md)
- Labels/claiming protocol: [`docs/specs/dev/GITHUB_LABELS.md`](specs/dev/GITHUB_LABELS.md)
- Error handling + escalation: [`docs/specs/dev/ERROR_HANDLING.md`](specs/dev/ERROR_HANDLING.md)
- Dev harness specs: `docs/specs/dev/`

## Copilot CLI + GitHub MCP integration

ReviewCat invokes **Copilot CLI** via subprocess and records each call in a
prompt ledger so runs can be inspected and (eventually) replayed in tests.

For GitHub operations (issues/PRs/comments), ReviewCat uses the **GitHub MCP
Server** via Copilot CLI’s MCP configuration. This keeps GitHub API usage
consistent across agents and reduces reliance on ad-hoc `gh` CLI scripting.

Canonical details live in specs:

- `docs/specs/app/systems/CopilotRunnerSystem.md`
- `docs/specs/dev/systems/GitHubOpsSystem.md` (when implemented)

## Safety model

- Default to **dry-run** and minimal permissions.
- Prefer allowlists for tools and explicit opt-in for mutations.
- PR-gated changes (no direct writes to `main`).

## Navigation

- Docs landing page: [`docs/INDEX.md`](INDEX.md)
- Project plan: [`PLAN.md`](../PLAN.md)
- Task list: [`TODO.md`](../TODO.md)
- Swarm operating contract: [`AGENT.md`](../AGENT.md)
