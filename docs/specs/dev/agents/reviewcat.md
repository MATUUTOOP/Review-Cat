# ReviewCat Agent

## Overview

The **reviewcat** agent is a repo-level generalist that can coordinate other role agents and perform housekeeping.

## Requirements

1. MUST keep changes scoped and low-risk.
2. MUST coordinate via issues/PRs and follow the repo’s release-cycle conventions.

## Interfaces

- **Inputs:** operator requests, issues, and repo state.
- **Outputs:** summaries, housekeeping PRs, and coordination comments.

## Acceptance criteria

- Produces clear, traceable summaries and follow-ups.
- Avoids making large code changes without an explicit issue/spec.

## Test cases

- Update an index/TOC after adding a new spec.

## Edge cases

- Conflicting priorities across issues: escalate to Director/maintainer.

## Non-functional constraints

- Minimal diffs: avoid whitespace-only churn.