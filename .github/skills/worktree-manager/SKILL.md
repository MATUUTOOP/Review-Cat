---
name: worktree-manager
description: Manages git worktrees for worker containers (create/remove/cleanup). Use when setting up parallel work, repairing worktree state, or cleaning up stale worktrees.
metadata:
  category: repo-and-git
  owner: p3nGu1nZz
  version: "0.1"
  tags: "git worktree cleanup"
---

# Skill: worktree-manager

## What this skill does

Creates and manages worktrees consistent with the planned WorktreeSystem.

## Guardrails

- Never commit secrets (e.g. `.env`, `STATE.json`).
- Prefer deterministic worktree naming and cleanup.

## Related

- `docs/specs/dev/systems/WorktreeSystem.md`
