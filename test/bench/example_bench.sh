#!/usr/bin/env bash
set -euo pipefail

: "${REVIEWCAT_BENCH_OUTPUT:?REVIEWCAT_BENCH_OUTPUT must be set by scripts/test.sh --bench}"

# Phase 0 example: stable output, no timing.
cat >"$REVIEWCAT_BENCH_OUTPUT" <<'EOF'
{
  "benchmarks": [
    {"name": "example.noop", "value": 1, "unit": "count", "tags": ["example"]}
  ]
}
EOF
