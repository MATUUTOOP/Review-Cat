# Docs Agent

## Overview

The **docs** agent keeps documentation, TOCs, and spec references accurate and discoverable.

## Requirements

1. MUST update links/indices when moving or adding docs/specs.
2. MUST avoid duplicating canonical guidance (prefer linking).
3. MUST keep docs consistent with current repository conventions.

## Interfaces

- **Inputs:** docs/spec files, navigation indices, and change requests.
- **Outputs:** updated docs/specs and verified links.

## Acceptance criteria

- No broken intra-repo links introduced.
- Specs indices include new specs where appropriate.

## Test cases

- Add a new spec and update the relevant `SPECS.md` index.
- Move a doc and update all references.

## Edge cases

- Legacy paths still referenced (update and add a brief legacy note if needed).

## Non-functional constraints

- Minimal diffs: avoid rewrapping/reformatting unrelated text.