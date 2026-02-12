# ReviewFinding component

## Overview

`ReviewFinding` is the normalized data structure used for persona outputs and synthesis input.

It is intentionally strict to keep outputs parseable, deduplicatable, and easy to turn into an action plan.

## Requirements

1. Must be serializable to JSON with stable field names.
2. Must support best-effort file and line mapping.
3. Must represent severity with a fixed enum.
4. Must include enough text to be useful without opening the codebase.

## Interfaces

JSON shape:

- `file`: string
- `line_start`: integer (optional or 0 if unknown)
- `line_end`: integer (optional or 0 if unknown)
- `severity`: `critical|high|medium|low|nit`
- `title`: string
- `description`: string
- `rationale`: string
- `suggested_fix`: string
- `suggested_patch`: string (optional)
- `confidence`: number in [0.0, 1.0]

## Acceptance criteria

- A persona prompt can produce an array of `ReviewFinding` instances that validate against the schema.
- Synthesis can merge two findings that are identical except for confidence or wording.
- Findings with unknown lines remain valid and still show the file.

## Test cases

- Validate a minimal finding (no patch, unknown lines).
- Validate a full finding (with patch and lines).
- Reject invalid severity.
- Reject confidence outside [0, 1].

## Edge cases

- Renamed files: file path in diff differs from current path.
- Binary files: no lines.
- Multi-hunk changes: line mapping ambiguous.

## Non-functional constraints

- Deterministic serialization (stable field ordering if using pretty JSON).
- No secrets in text fields (must be passed through redaction rules).
