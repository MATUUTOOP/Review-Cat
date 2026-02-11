# Long-term engrams (LT)

Long-term engrams capture stable conventions, repeated lessons, and durable decisions.

They are intended to be:

- append-only and reviewable
- referenced by agents when making architectural or workflow decisions
- kept smaller in number but higher in signal

Engram batches live under `memory/lt/<batch_id>/`.

## On-disk layout (normative)

Long-term engrams are stored as:

- `memory/lt/<batch_id>/engram_<engram_id>.json`

Where:

- `<batch_id>` is UTC `YYYYMMDD-HHMMSSZ` (example: `20260101-000000Z`)
- `<engram_id>` is filename-safe (recommended: `e_<ulid>`)
