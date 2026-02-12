# EngramCatalogDTO (Director LUT)

## Overview

The **EngramCatalogDTO** is the Director’s authoritative lookup table (LUT) describing the current shared memory set.

It enables:

- verifying all agents have the same engram set
- fast “what changed” comparisons
- safe distribution of memory snapshots over the agent bus

## Requirements

### Fields

- `catalog_version` — monotonically increasing integer or timestamp
- `created_at` — ISO-8601
- `hash` — content hash of the catalog
- `entries` — mapping/list of:
  - `engram_id`
  - `scope` (`st`|`lt`)
  - `version`
  - `path` (repo-relative)
  - `hash`
  - `topics` (optional)

### Consistency rules

- Catalog hash must be computed from a canonical representation.
- The Director publishes the authoritative catalog.
- Workers reconcile by comparing:
  - `catalog_version` then `hash`

## Interfaces

### Agent bus

- Director may broadcast catalog snapshots.
- Workers may request refresh.

### Git

- Catalog changes are reflected by new/updated engram files under `/memory/`.

The catalog itself is stored as a tracked file at:

- `memory/catalog.json`

Each `entries[].path` MUST point at an engram JSON using the normative layout:

- `memory/{st|lt}/<batch_id>/engram_<engram_id>.json`

## Acceptance criteria

- Workers can determine if their local worktree is missing engrams by comparing catalog entries.
- Catalog supports partial sync (only ST or LT) if needed.

## Test cases

- Given a new catalog entry, a worker can detect it is missing the referenced engram path.
- Given a canonically serialized catalog, hashing is stable across hosts.

## Edge cases

- Duplicate `engram_id` entries (reject or deterministic last-write-wins).
- Missing referenced engram path (worker requests refresh / reports).

## Non-functional constraints

- Determinism: hashing must be stable across hosts.
- Size: catalog should remain small enough to broadcast over the agent bus.

## Example (non-normative)

File path:

- `memory/catalog.json`

Example JSON:

```json
{
  "catalog_version": "20260211-231800Z",
  "created_at": "2026-02-11T23:18:00Z",
  "hash": "sha256:...",
  "entries": [
    {
      "engram_id": "e_01J1Z2K3M4N5P6Q7R8S9T0V1W2",
      "scope": "st",
      "version": "20260211-231715Z",
      "path": "memory/st/20260211-231715Z/engram_e_01J1Z2K3M4N5P6Q7R8S9T0V1W2.json",
      "hash": "sha256:...",
      "topics": ["memory", "workflow"]
    }
  ]
}
```
