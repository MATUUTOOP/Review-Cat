# AuditIdFactory entity

## Overview

`AuditIdFactory` generates unique audit IDs used for audit directory names and indexes.

## Requirements

1. IDs must be unique across runs.
2. IDs must be filesystem-safe.
3. IDs should be sortable by time.
4. IDs may include a short commit hash when available.

## Interfaces

- `new_audit_id(created_at, head_commit?) -> string`

Format recommendation:

- `YYYYMMDD-HHMMSS-<shortsha>`

## Acceptance criteria

- Two runs in the same second still produce distinct IDs.
- IDs never include path separators.

## Test cases

- Deterministic output given fixed timestamp and nonce.
- Commit hash inclusion when provided.

## Edge cases

- No git available.

## Non-functional constraints

- Must not leak absolute paths.
