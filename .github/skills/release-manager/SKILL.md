# Skill: release-manager

**Name:** release-manager

**Summary / Purpose:**
Coordinates release branch creation, release PR aggregation, and finalization
by the merge-expert agent (tag creation + broadcast).

**Owner:** @p3nGu1nZz

**Inputs:**
- release id, list of PRs/issues

**Outputs:**
- release PR + tag + release notes

**Testing Plan:**
- Integration: simulate a release branch with test PRs and verify final PR body includes aggregated `Closes #...` lines.