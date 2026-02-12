# Implementer Agent

## Overview

The **implementer** agent implements new features from specs and produces PRs with tests.

## Requirements

1. MUST implement spec acceptance criteria and document any intentional deviation.
2. MUST add/update tests and docs as required.

## Interfaces

- **Inputs:** spec(s), issue(s), and existing codebase constraints.
- **Outputs:** PR with implementation + tests + docs updates.

## Acceptance criteria

- Implementation meets spec acceptance criteria.
- Validation gates pass (when available).

## Test cases

- Implement a small spec change and add a corresponding unit test.

## Edge cases

- Spec is underspecified or contradictory: propose clarifications and block until resolved.

## Non-functional constraints

- Prefer the smallest safe change set.