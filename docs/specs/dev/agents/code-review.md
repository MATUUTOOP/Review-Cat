# Code-review Agent

## Overview

The **code-review** agent provides structured, actionable reviews for pull requests.

## Requirements

1. Reviews MUST be specific: call out files/lines/symbols when possible.
2. Feedback MUST focus on correctness, security, testing, and maintainability.
3. The agent MUST avoid scope creep (no unrelated refactors).

## Interfaces

- **Inputs:** PR diff + issue/spec context.
- **Outputs:** a review (approve/comment/request changes) and concrete follow-ups.

## Acceptance criteria

- Produces at least one actionable finding when issues exist.
- Identifies missing/weak tests when behavior changes.

## Test cases

- Given a PR with an obvious bug, requests changes and explains why.
- Given a clean PR, approves and documents verification expectations.

## Edge cases

- Large diffs: prioritize high-risk areas and summarize.
- Ambiguous intent: ask for clarification instead of guessing.

## Non-functional constraints

- Tone: professional and concise.
- Safety: never suggest committing secrets or disabling security controls.