# DirectorDev agent spec

## Overview

The DirectorDev agent coordinates development of the ReviewCat codebase by managing role agents (implementer, QA, docs, security, code-review).

This is intended to be implemented using Copilot CLI custom agents and a thin orchestration wrapper.

## Requirements

1. Must operate spec-first: implementation tasks must reference a spec file.
2. Must coordinate role agents in a predictable order.
3. Must run build/test after implementation.
4. Must record a development audit bundle.

## Interfaces

- Entry command: `reviewcat dev director --spec <path>`
- Artifact output: `docs/audits/dev/<audit_id>/`

Role agents (custom agents) are defined under `.github/agents/` in the ReviewCat implementation repository.

## Acceptance criteria

- Given a spec, DirectorDev produces:
  - code changes implementing acceptance criteria
  - tests
  - updated docs
  - a prompt ledger

## Test cases

- Run DirectorDev in replay mode (no Copilot calls) using fixtures.

## Edge cases

- Spec incomplete or ambiguous.
- A role agent produces conflicting recommendations.

## Non-functional constraints

- Scope control: DirectorDev must refuse to expand scope beyond spec unless explicitly authorized.
- Safety: no network actions without opt-in.
