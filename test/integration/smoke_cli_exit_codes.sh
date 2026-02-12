#!/usr/bin/env bash
set -euo pipefail

build_dir="${REVIEWCAT_BUILD_DIR:-build}"

find_reviewcat() {
  local candidates=(
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

  echo "reviewcat binary not found under $build_dir/" >&2
  return 1
}

bin="$(find_reviewcat)"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

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
  exit 1
fi
