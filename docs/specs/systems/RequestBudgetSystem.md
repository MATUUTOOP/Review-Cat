# RequestBudgetSystem (Rate Limits + Backpressure)

## Overview

`RequestBudgetSystem` defines **how the swarm paces external requests** so parallel agents do not overload:

- GitHub (via GitHub MCP Server and/or `gh` CLI)
- LLM/model calls (via Copilot CLI)
- any other remote dependency added later

This is a **swarm-level backpressure policy**: even if workers run in parallel, outbound requests must be scheduled to keep the system stable.

## Goals

- Prevent request floods (thundering herd) when many workers start at once.
- Provide predictable throughput and latency under concurrency.
- Make retry/backoff behavior consistent across Director + workers.
- Keep the swarm “polite” to remote services and avoid cascading failures.

## Non-goals

- Precisely mirroring every upstream provider’s rate limit semantics.
- Storing credentials or secrets (all tokens remain environment variables).

## Requirements

1. **Central coordination:** The Director MUST be able to enforce global budgets (even if workers also enforce local budgets).
2. **Separate budgets by resource:** At minimum, maintain separate budgets for:
   - `github.read`
   - `github.write`
   - `model.request`
3. **Backoff + jitter:** On transient failures, apply exponential backoff with jitter.
4. **Retry-After aware:** If a response includes `Retry-After` (or equivalent), the scheduler MUST respect it.
5. **Circuit breaker:** If repeated failures occur, open a circuit breaker for that resource for a cooldown window.
6. **Fairness:** Requests from many workers should be served fairly (avoid starvation).
7. **Observability:** Director logs MUST record:
   - queued vs executed request counts
   - current cooldown state
   - last error reason (redacted)

## Policy model

### A) Token bucket / leaky bucket

A practical policy is:

- **Token bucket** for steady-state pacing (requests per time window)
- **Max concurrency** cap to avoid connection storms
- **Write pacing** stricter than read pacing

### B) Priority

Suggested priority order when budgets are tight:

1. Worker heartbeats / liveness
2. PR merge checks / safety gates
3. Issue/PR reads needed for current tasks
4. Best-effort reads (listing, searching)
5. Writes that are not required for correctness (cosmetic comments)

## GitHub-specific guidance (high-level)

GitHub enforces multiple layers of throttling, including burst/abuse protections. The swarm should treat GitHub as:

- **cheap-ish reads** (but still bounded)
- **expensive writes** (pace aggressively; serialize or near-serialize)

Behavioral rules:

- Prefer batching reads where possible (e.g., list issues once per heartbeat).
- Deduplicate repeated reads across workers (Director can broadcast snapshots).
- Gate writes behind validation (build/test passed) and keep them minimal.
- On any rate limit / abuse indication, enter a cooldown and reduce concurrency.

## Model (Copilot/LLM) request guidance

Model calls can be the most expensive dependency for the swarm.

Behavioral rules:

- Limit concurrent model calls globally.
- Prefer fewer, higher-quality prompts over repeated retries.
- On model errors, back off and avoid immediate re-tries by multiple workers.
- When possible, use deterministic validation gates (build/test) instead of extra model calls.

## Interfaces (planning-level)

### Director-facing

- `acquire(resource, kind, worker_id) -> grant_id | queued`
- `release(grant_id) -> void`
- `report_result(grant_id, status, retry_after_seconds?) -> void`

Where `resource` is one of: `github`, `model`, and `kind` is `read`/`write`.

### Worker-facing

Workers SHOULD implement a small local limiter (to avoid tight loops), but MUST defer to Director when in `director_broker` mode.

## Configuration

See `config/dev.toml`:

- `[rate_limits.github]`
  - `max_concurrent_requests`
  - `min_seconds_between_writes`
  - `cooldown_on_rate_limit_seconds`
- `[rate_limits.model]`
  - `max_concurrent_requests`
  - `min_seconds_between_requests`
  - `cooldown_on_error_seconds`

## Acceptance criteria

- With `max_workers > 1`, outbound GitHub/model requests remain bounded.
- Under induced 429-like failures, the swarm backs off (no tight loops).
- Writes are paced and do not occur in bursts.
- Director logs clearly show when the swarm is in cooldown.

## Edge cases

- Multiple workers all failing at once (must avoid synchronized retries).
- MCP timeouts that look like rate limiting (treat as transient; back off).
- `gh` fallback calls (still count against GitHub budgets).
