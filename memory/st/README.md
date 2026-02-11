# Short-term engrams (ST)

Short-term engrams are compact, structured memory artifacts derived from older slices of the agent-bus event stream.

They are intended to be:

- highly relevant to current work
- relatively small
- safe to load/grep frequently

Engram batches live under `memory/st/<batch_id>/`.

## On-disk layout (normative)

Short-term engrams are stored as:

- `memory/st/<batch_id>/engram_<engram_id>.json`

Where:

- `<batch_id>` is UTC `YYYYMMDD-HHMMSSZ` (example: `20260211-231715Z`)
- `<engram_id>` is filename-safe (recommended: `e_<ulid>`)
