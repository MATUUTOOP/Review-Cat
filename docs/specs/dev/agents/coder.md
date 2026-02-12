# Coder Agent

## Overview

The **coder** agent reads GitHub issues and implements fixes/features with tests and a PR.

## Requirements

1. MUST keep changes minimal and relevant to the issue.
2. MUST add or update tests for behavioral changes.
3. MUST run the validation gate when available (`./scripts/build.sh && ./scripts/test.sh`).

## Interfaces

- **Inputs:** issue text, linked specs, and repo context.
- **Outputs:** a PR that references the issue and documents validation.

## Acceptance criteria

- PR satisfies the issue acceptance checklist (or explains deviations).
- PR passes validation gates (when implemented).

## Test cases

- Given a simple bug issue, produces a fix + a regression test.
- Given a doc-only issue, produces only documentation changes.

## Edge cases

- Build/test scripts missing: report as blocked and file follow-up.
- Conflicting guidance between issue and specs: follow specs and escalate mismatch.

## Non-functional constraints

- Safety: do not introduce secret material into repo or logs.
- Maintainability: avoid drive-by refactors.