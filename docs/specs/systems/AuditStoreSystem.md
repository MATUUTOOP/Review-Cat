# AuditStoreSystem

## Overview

`AuditStoreSystem` writes audit artifacts to disk and maintains indexes.

## Requirements

1. Must create `docs/audits/<audit_id>/`.
2. Must write `audit.json`, persona outputs, unified outputs, and ledger.
3. Must update `docs/audits/index.json`.
4. Must support archiving older audits.

## Interfaces

- `write_audit(audit_record, artifacts)`
- `update_index(audit_record)`
- `archive(audit_id|before_date)`

## Acceptance criteria

- All artifact writes are relative paths.
- Index update is atomic (write temp then rename).

## Test cases

- Write audit directory structure.
- Index update merges new record.

## Edge cases

- Existing audit_id collision.
- Missing docs directory.

## Non-functional constraints

- Never delete without explicit command.
- Deterministic index ordering.
