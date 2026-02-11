# DirectorDev workflow (recursive development coordination)

This document specifies how the ReviewCat project is intended to "build itself" using GitHub Copilot CLI, with a Director agent coordinating multiple role agents.

The key intent is not full autonomy. The intent is:

- consistent decomposition
- explicit acceptance criteria
- repeatable build/test loops
- recorded evidence of Copilot CLI usage

## Roles

DirectorDev coordinates these roles:

- Director: decomposes work, enforces scope, merges outputs, validates acceptance.
- Architect: reviews architecture changes, watches complexity.
- Implementer: writes code.
- QA: writes tests and adds record/replay fixtures.
- Docs: maintains README, examples, prompt cookbook.
- Security: enforces safe defaults, redaction, permission policy.
- Code-review: reviews diffs and blocks low-signal changes.

In Copilot CLI, these roles are expressed as custom agents.

## Inputs

- A target spec file in `reviewcat_design/specs/`.
- Current repository state.
- Optional constraints:
  - language choice
  - time budget
  - risk tolerance (dry-run vs automation)

## Outputs

- Code changes implementing the spec.
- Tests proving acceptance criteria.
- Updated docs.
- A development audit bundle under `docs/audits/dev/<audit_id>/`:
  - prompt ledger
  - agent outputs
  - build/test logs

## Orchestration algorithm

1. Director loads spec and extracts:
   - requirements
   - interfaces
   - acceptance criteria
   - test cases
2. Director creates a task graph:
   - each node is assigned to a role agent
   - dependencies enforce order (spec -> implementation -> tests -> docs -> review)
3. Director runs role agents sequentially (default) with explicit checkpoints:
   - after each agent, Director summarizes changes and decides whether to continue.
4. Director runs validation:
   - build
   - unit tests
   - demo mode (if relevant)
5. Director requests a final code review pass.
6. Director writes a short completion note and updates `docs/audits/dev/index.json`.

## Guardrails

- Dry-run is default.
- Tool permissions are restricted unless user explicitly opts in.
- Director must refuse to:
  - modify files outside repo scope without explicit approval
  - post to GitHub without explicit flags
  - run destructive commands

## Recursive behavior

DirectorDev is recursive in the sense that:

- if a spec requires new subsystems, DirectorDev creates additional specs first
- each new spec becomes a new loop iteration

This keeps work modular and avoids monolithic changes.

## How to demonstrate this to judges

- Run one small DirectorDev cycle during your demo recording.
- Show:
  - the spec file
  - the resulting code change
  - the test run
  - the prompt ledger

The prompt ledger is the proof that Copilot CLI was used meaningfully, not just incidentally.
