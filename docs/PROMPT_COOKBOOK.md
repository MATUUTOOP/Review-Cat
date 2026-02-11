# Prompt cookbook

This is a curated set of prompt patterns used by ReviewCat.

The intent is consistency and easy judge visibility.

## Persona prompt contract

All persona prompts must request output in strict JSON, as an array of findings.

Each finding:

- file
- line_start
- line_end
- severity: critical|high|medium|low|nit
- title
- description
- rationale
- suggested_fix
- suggested_patch (optional, unified diff)
- confidence: 0.0..1.0

## Persona: security

Prompt pattern:

- Input: diff hunks and minimal context.
- Output: vulnerabilities, exploitability, unsafe defaults, data leak risks.
- Require: at least one concrete fix suggestion per finding.

## Persona: performance

Prompt pattern:

- Focus on algorithmic complexity, hot paths, allocations, I/O.
- Require: explain impact and conditions.

## Persona: architecture

Prompt pattern:

- Focus on module boundaries, naming, dependency direction.
- Require: propose refactors only if they reduce complexity.

## Persona: testing

Prompt pattern:

- Identify missing tests and propose concrete test cases.

## Persona: docs

Prompt pattern:

- Identify missing usage docs and confusing behaviors.

## Synthesis prompt

Prompt pattern:

- Input: all persona JSON outputs.
- Output:
  - unified review markdown
  - merged finding list with dedupe rationale
  - action plan JSON suitable for GitHub issues

## Patch planning prompt

Prompt pattern:

- Input: prioritized findings.
- Output: small safe patches.
- Constraints:
  - avoid broad refactors
  - prefer tests first
  - no unrelated formatting changes

## DirectorDev planning prompt

Prompt pattern:

- Input: a spec file.
- Output:
  - task graph
  - role assignments
  - exact acceptance criteria mapping
