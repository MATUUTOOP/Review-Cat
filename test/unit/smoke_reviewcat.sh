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

  echo "reviewcat binary not found under $build_dir/ (did you run scripts/build.sh?)" >&2
  return 1
}

bin="$(find_reviewcat)"

"$bin" --help >/dev/null
"$bin" --version | grep -q "^reviewcat "
