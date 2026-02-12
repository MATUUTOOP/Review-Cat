---
name: release-manager
description: Coordinates the release cycle (release branch + aggregate release PR). Use when preparing a release, rolling up worker PRs, or finalizing release notes.
metadata:
  category: repo-and-git
  owner: p3nGu1nZz
  version: "0.1"
  tags: "release branch pr aggregation"
---

# Skill: release-manager

## What this skill does

- Creates/updates a release branch
- Aggregates worker PRs into a single release PR
- Ensures issue-closing semantics match the repo's release model

## Guardrails

- Worker PRs should reference issues (e.g., `Refs #123`) but generally should not close them directly.
- The release PR is responsible for `Closes #...` lines when appropriate.

## Related

- `docs/specs/dev/systems/ReleaseCycleSystem.md`
- `AGENT.md` (release model)
