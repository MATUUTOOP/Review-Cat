# EngramDTO

## Overview

An **EngramDTO** is a structured, versioned memory artifact produced by compacting older slices of the agent-bus event stream.

Engrams are intended to be:

- **durable** (git-tracked under `/memory/`)
- **shareable** across agents and hosts
- **verifiable** (hash-identified)
- **reviewable** (PR-friendly diffs)

## Requirements

### Fields

An Engram must contain enough metadata to validate and route it:

- `engram_id` — stable identifier (string)
- `version` — **batch id** (UTC timestamp; see Storage)
- `scope` — `st` | `lt`
- `created_at` — ISO-8601
- `source_window` — {`start_ts`, `end_ts`} for the compacted event slice
- `hash` — content hash (e.g., sha256 of canonical JSON)
- `topics` — array of keywords/tags
- `facts` — array of extracted facts (short, actionable)
- `decisions` — array of decisions with rationale
- `links` — references to issues/PRs/specs/files
- `provenance` — who/what created it (director/worker id, run id)

### Canonicalization

- The JSON representation must be canonicalizable to produce stable hashes.
- Engrams should be treated as **append-only** once merged; prefer writing new versions.

## Interfaces

### Storage

Engrams are stored under repo-tracked `/memory/` as JSON files.

**Normative path format:**

- `memory/st/<batch_id>/engram_<engram_id>.json`
- `memory/lt/<batch_id>/engram_<engram_id>.json`

Where:

- `<batch_id>` MUST be UTC `YYYYMMDD-HHMMSSZ` (example: `20260211-231715Z`).
	- The EngramDTO `version` MUST equal `<batch_id>`.
- `<engram_id>` MUST be stable and filename-safe.
	- recommended: `e_<ulid>`
	- allowed characters: `A-Z a-z 0-9 _ -`

Rationale:

- batch directories keep PR diffs localized and reduce merge conflicts
- timestamp batch ids keep ordering predictable across worktrees

## Acceptance criteria

- An EngramDTO schema is defined and can be validated.
- Two agents given the same canonical JSON produce the same `hash`.
- Engrams can be searched/grepped by id, topic, linked issue, or decision.

## Example (non-normative)

Example file path:

- `memory/st/20260211-231715Z/engram_e_01J1Z2K3M4N5P6Q7R8S9T0V1W2.json`

Example JSON:

```json
{
	"engram_id": "e_01J1Z2K3M4N5P6Q7R8S9T0V1W2",
	"version": "20260211-231715Z",
	"scope": "st",
	"created_at": "2026-02-11T23:17:15Z",
	"source_window": {"start_ts": "2026-02-11T22:50:00Z", "end_ts": "2026-02-11T23:10:00Z"},
	"hash": "sha256:...",
	"topics": ["memory", "workflow", "governance"],
	"facts": [
		"Workers MUST treat MEMORY.md as read-only; Director-only writes."
	],
	"decisions": [
		{"title": "Standardize engram file layout", "rationale": "Keep PR diffs localized and reduce merge conflicts."}
	],
	"links": [
		{"type": "issue", "ref": "#13"},
		{"type": "file", "ref": "memory/README.md"}
	],
	"provenance": {"created_by": "MemoryAgent", "run_id": "run_..."}
}
```

## Notes

Engrams are not intended to store secrets. Any token-like content must be redacted.
