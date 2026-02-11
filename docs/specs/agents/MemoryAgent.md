# MemoryAgent (Engram Extractor + Compactor)

## Overview

The **MemoryAgent** is responsible for turning older, low-level swarm experience into compact, durable shared memory.

It operates as a supporting agent invoked by the Director.

## Responsibilities

- Consume (or be provided) slices of the normalized agent-bus event buffer.
- Extract stable facts/decisions/lessons.
- Produce structured **EngramDTO** files under `/memory/st/<batch_id>/` and/or `/memory/lt/<batch_id>/`.
- Ensure file paths follow the normative format:
  - `memory/{st|lt}/<batch_id>/engram_<engram_id>.json`
- Propose a catalog update when needed (`memory/catalog.json` remains Director-authoritative).
- Propose changes via a PR.

## Inputs

- Event slice (bounded window) with timestamps and topics.
- Current `EngramCatalogDTO` and any existing engrams.
- Memory budget constraints from `config/dev.toml`.

## Outputs

- New engram files (append-only preference).
- Optional catalog update proposal (Director remains authoritative).
- A short PR description explaining:
  - what was compacted
  - why items were promoted to LT
  - how size budget improved

## Rules and constraints

- Must not include secrets.
- Must compact **oldest-first**.
- Must avoid rewriting existing engrams unless strictly necessary.
- Must keep each engram small and high-signal.

## Acceptance criteria

- Produces EngramDTOs that validate and hash deterministically.
- Reduces memory pressure by allowing eviction of older raw events.
- Keeps durable memory queryable by other agents.

## Notes

This agent is complementary to the “memory query skill” used by other workers to search ST/LT engrams during tasks.
