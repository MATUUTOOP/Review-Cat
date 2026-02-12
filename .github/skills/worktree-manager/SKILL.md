# Skill: worktree-manager

**Name:** worktree-manager

**Summary / Purpose:**
Manage git worktrees used by worker containers: creation, removal, naming,
and cleanup.

**Owner:** @p3nGu1nZz

**Inputs:**
- branch name, worktree path template

**Outputs:**
- created worktree directory ready for use

**Testing Plan:**
- Integration: create temporary worktree and verify it contains correct branch.
