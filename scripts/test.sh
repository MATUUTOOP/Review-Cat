#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

build_dir="${REVIEWCAT_BUILD_DIR:-build}"

run_unit=0
run_integration=0
run_bench=0

junit_output=""
bench_output=""

usage() {
  cat <<'EOF'
Usage: scripts/test.sh [--unit|--integration|--bench|--all] [--junit-output <path>] [--bench-output <path>]

Defaults:
  If no suite flags are provided, runs --unit.

Environment:
  REVIEWCAT_BUILD_DIR   Override build directory (default: build)
EOF
}

if [[ $# -eq 0 ]]; then
  run_unit=1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --unit)
      run_unit=1; shift 1 ;;
    --integration)
      run_integration=1; shift 1 ;;
    --bench)
      run_bench=1; shift 1 ;;
    --all)
      run_unit=1; run_integration=1; run_bench=1; shift 1 ;;
    --junit-output)
      junit_output="${2:-}"; shift 2 ;;
    --bench-output)
      bench_output="${2:-}"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

# Ensure we have a build directory. (The green gate typically calls build.sh first,
# but test.sh is safe to run standalone.)
if [[ ! -d "$build_dir" ]]; then
  ./scripts/build.sh
fi

failures=0

run_ctest_label() {
  local label="$1"
  if ! command -v ctest >/dev/null 2>&1; then
    echo "ctest not found; cannot run CMake-registered tests" >&2
    return 1
  fi

  local ctest_args=("--test-dir" "$build_dir" "--output-on-failure")
  if [[ -n "$label" ]]; then
    ctest_args+=("-L" "$label")
  fi

  echo "Running ctest (label=$label)"
  ctest "${ctest_args[@]}"
}

run_sh_dir() {
  local dir="$1"
  local kind="$2"

  if [[ ! -d "$dir" ]]; then
    return 0
  fi

  shopt -s nullglob
  local scripts=("$dir"/*.sh)
  shopt -u nullglob

  if [[ ${#scripts[@]} -eq 0 ]]; then
    return 0
  fi

  echo "Running $kind shell tests under $dir/"
  for f in "${scripts[@]}"; do
    echo "- $f"
    bash "$f"
  done
}

unit_rc=0
integration_rc=0
bench_rc=0

if [[ "$run_unit" -eq 1 ]]; then
  if ! run_ctest_label "unit"; then
    unit_rc=$?
    failures=1
  fi
  if ! run_sh_dir "test/unit" "unit"; then
    unit_rc=$?
    failures=1
  fi
fi

if [[ "$run_integration" -eq 1 ]]; then
  # No CMake tests are labeled integration yet; this is here for future expansion.
  if ! run_ctest_label "integration"; then
    integration_rc=$?
    failures=1
  fi
  if ! run_sh_dir "test/integration" "integration"; then
    integration_rc=$?
    failures=1
  fi
fi

if [[ "$run_bench" -eq 1 ]]; then
  if [[ -z "$bench_output" ]]; then
    bench_output="$build_dir/bench.json"
  fi

  mkdir -p "$(dirname "$bench_output")"
  # Initialize a stable file even when no benches exist.
  echo '{"benchmarks":[]}' >"$bench_output"

  export REVIEWCAT_BENCH_OUTPUT="$bench_output"

  if ! run_sh_dir "test/bench" "bench"; then
    bench_rc=$?
    failures=1
  fi

  echo "Bench output: $bench_output"
fi

if [[ -n "$junit_output" ]]; then
  mkdir -p "$(dirname "$junit_output")"

  # Simple aggregate JUnit output. This is intentionally minimal (Phase 0):
  # it guarantees CI consumers have a file to parse.
  tests=1
  failures_count=0
  failure_body=""
  if [[ "$failures" -ne 0 ]]; then
    failures_count=1
    failure_body="<failure message=\"test suite failed\">See logs for details.</failure>"
  fi

  cat >"$junit_output" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="reviewcat" tests="$tests" failures="$failures_count">
  <testcase classname="scripts.test" name="aggregate">$failure_body</testcase>
</testsuite>
EOF

  echo "JUnit output: $junit_output"
fi

if [[ "$failures" -ne 0 ]]; then
  exit 1
fi
