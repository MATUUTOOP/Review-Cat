#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

target="${REVIEWCAT_TARGET:-linux64}"
config="Debug"

build_root="${REVIEWCAT_BUILD_ROOT:-build}"
build_dir="${REVIEWCAT_BUILD_DIR:-}"

do_build=1

run_unit=0
run_integration=0
run_bench=0

junit_output=""
bench_output=""

usage() {
  cat <<'EOF'
Usage: scripts/test.sh [unit|integration|bench|all] [options]

Suite selection (flags still supported for compatibility):
  unit         Run unit tests (Catch2 via CTest label 'unit')
  integration  Run integration smoke tests
  bench        Produce bench JSON output
  all          Run everything

Options:
  --target linux64|win64     Build target platform (default: linux64)
  --config Debug|Release     Build type when auto-building (default: Debug)
  --no-build                 Do not auto-build if build dir is missing
  --junit-output <path>      Write aggregate JUnit XML
  --bench-output <path>      Bench JSON output path (default: build/<target>/bench.json)

Defaults:
  If no suite flags are provided, runs --unit.

Environment:
  REVIEWCAT_TARGET      Default --target (default: linux64)
  REVIEWCAT_BUILD_ROOT  Root build dir (default: build)
  REVIEWCAT_BUILD_DIR   Override build directory (default: build/<target>)
EOF
}

if [[ $# -eq 0 ]]; then
  run_unit=1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    unit)
      run_unit=1; shift 1 ;;
    integration)
      run_integration=1; shift 1 ;;
    bench)
      run_bench=1; shift 1 ;;
    all)
      run_unit=1; run_integration=1; run_bench=1; shift 1 ;;
    --unit)
      run_unit=1; shift 1 ;;
    --integration)
      run_integration=1; shift 1 ;;
    --bench)
      run_bench=1; shift 1 ;;
    --all)
      run_unit=1; run_integration=1; run_bench=1; shift 1 ;;
    --target)
      target="${2:-}"; shift 2 ;;
    --target=*)
      target="${1#*=}"; shift 1 ;;
    --config)
      config="${2:-}"; shift 2 ;;
    --config=*)
      config="${1#*=}"; shift 1 ;;
    --no-build)
      do_build=0; shift 1 ;;
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

if [[ "$config" != "Debug" && "$config" != "Release" ]]; then
  echo "Invalid --config: $config (expected Debug or Release)" >&2
  exit 2
fi

case "$target" in
  linux64|win64) ;;
  *)
    echo "Invalid --target: $target (expected linux64 or win64)" >&2
    exit 2
    ;;
esac

if [[ -z "$build_dir" ]]; then
  build_dir="$build_root/$target"
fi

# Ensure we have a build directory. (The green gate typically calls build.sh first,
# but test.sh is safe to run standalone.)
if [[ ! -d "$build_dir" ]]; then
  if [[ "$do_build" -ne 1 ]]; then
    echo "Build dir not found: $build_dir (and --no-build was provided)" >&2
    exit 2
  fi
  ./scripts/build.sh dev --target "$target" --config "$config"
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

find_reviewcat() {
  local candidates=(
    "$build_dir/bin/reviewcat"
    "$build_dir/bin/reviewcat.exe"

    # Back-compat for manually configured build dirs.
    "$build_dir/reviewcat"
    "$build_dir/app/reviewcat"
    "$build_dir/Debug/reviewcat"
    "$build_dir/Release/reviewcat"
  )

  for c in "${candidates[@]}"; do
    if [[ -x "$c" ]]; then
      echo "$c"
      return 0
    fi
  done

  echo "reviewcat binary not found under $build_dir/ (did you run scripts/build.sh?)" >&2
  return 1
}

run_integration_smoke() {
  local bin
  bin="$(find_reviewcat)"

  if [[ "$target" == "win64" ]]; then
    echo "Cannot execute win64 binaries on this host target; integration smoke requires a runnable binary." >&2
    return 2
  fi

  local tmp rc
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  # Help should succeed.
  "$bin" --help >"$tmp/help.txt"

  # Unknown args should fail with a stable non-zero code.
  set +e
  "$bin" --definitely-not-a-real-arg >/dev/null 2>"$tmp/err.txt"
  rc=$?
  set -e

  if [[ "$rc" -ne 2 ]]; then
    echo "Expected exit code 2 for unknown args, got $rc" >&2
    cat "$tmp/err.txt" >&2 || true
    return 1
  fi
}

unit_rc=0
integration_rc=0
bench_rc=0

if [[ "$run_unit" -eq 1 ]]; then
  if ! run_ctest_label "unit"; then
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
  if ! run_integration_smoke; then
    integration_rc=$?
    failures=1
  fi
fi

if [[ "$run_bench" -eq 1 ]]; then
  if [[ -z "$bench_output" ]]; then
    bench_output="$build_dir/bench.json"
  fi

  mkdir -p "$(dirname "$bench_output")"
  # Phase 0 bench output: stable output, no timing.
  cat >"$bench_output" <<'EOF'
{
  "benchmarks": [
    {"name": "example.noop", "value": 1, "unit": "count", "tags": ["example"]}
  ]
}
EOF

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
