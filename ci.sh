#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "=== CI: start ==="

# If a build.sh exists in repo root, try to make it executable (safe: only local)
if [ -f "../build.sh" ]; then
  chmod +x ../build.sh || true
  # If running locally (not in GitHub Actions) try to update git index to record exec bit
  if [ -z "${GITHUB_ACTIONS:-}" ] && command -v git >/dev/null 2>&1; then
    git update-index --add --chmod=+x ../build.sh || true
  fi
fi

# create build dir and enter
mkdir -p build
cd build

echo "--- cmake configure ---"
cmake .. || { echo "CMake configure failed"; exit 1; }

# determine parallelism
if command -v nproc >/dev/null 2>&1; then
  PARALLEL=$(nproc)
elif [[ "$(uname -s)" == "Darwin" ]]; then
  PARALLEL=$(sysctl -n hw.ncpu)
else
  PARALLEL=2
fi

echo "--- build ---"
cmake --build . --parallel "${PARALLEL}" || { echo "Build failed"; exit 1; }

echo "--- run tests (ctest) ---"
if command -v ctest >/dev/null 2>&1; then
  ctest --output-on-failure || { echo "Tests failed"; exit 1; }
else
  echo "ctest not found; skipping tests"
fi

# return to repo root
cd ..

echo "=== CI: done ==="
exit 0