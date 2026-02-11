# DirectorRuntimeSystem

## Overview

`DirectorRuntimeSystem` orchestrates the end-to-end review and fix flow
(input → personas → synthesis → issue creation → coding agent dispatch →
persistence → optional GitHub operations).

It is the runtime director (distinct from DirectorDev, which builds ReviewCat
itself). This system runs when end users invoke ReviewCat commands.

## Requirements

1. Must run the full pipeline in a fixed order.
2. Must support dry-run default.
3. Must surface clear terminal UX.
4. Must always write an audit record even if partial.
5. Must dispatch CodingAgentSystem for critical/high findings (when enabled).
6. Must create GitHub Issues from findings via GitHubOpsSystem (when enabled).
7. Must support the circular review→fix loop in watch/daemon mode.

## Interfaces

- `run_demo()` — bundled sample diff review
- `run_review(config)` — local diff review
- `run_pr(config)` — PR review via GitHub MCP
- `run_fix(config)` — review + auto-fix via coding agents
- `run_watch(config)` — daemon mode: poll → review → fix → repeat

## Pipeline

1. **RepoDiffSystem** — collect diffs
2. **PersonaReviewSystem** — run persona agents
3. **SynthesisSystem** — dedupe, prioritize, unify
4. **AuditStoreSystem** — persist artifacts
5. **GitHubOpsSystem** — create issues/PRs (optional)
6. **CodingAgentSystem** — dispatch coding agents (optional)
7. **PatchApplySystem** — apply patches (optional)

## Acceptance criteria

- A failure in any system produces a partial audit rather than losing artifacts.
- Terminal summary includes next steps.
- When enabled, findings with severity >= high generate GitHub Issues.
- When enabled, coding agents are dispatched for generated issues.

## Test cases

- Pipeline success path in replay mode.
- Persona failure path yields partial status.
- Watch mode polls at configured interval.
- Coding agent dispatch creates PRs for high-severity findings.

## Edge cases

- Repo without origin remote.
- Empty diff.
- GitHub MCP unavailable in watch mode.

## Non-functional constraints

- Deterministic ordering and output.
- Audit records for every run, even partial failures.
