#!/usr/bin/env bash
set -euo pipefail

echo "=== CI: start ==="

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
ctest --output-on-failure || { echo "Tests failed"; exit 1; }

# return to repo root
cd ..

echo "=== CI: done ==="
exit 0
```// filepath: d:\Git\repos\APKS_LABS\csad2526ki405denysiakmykolaandriyovich10\ci.sh
#!/usr/bin/env bash
set -euo pipefail

echo "=== CI: start ==="

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
ctest --output-on-failure || { echo "Tests failed"; exit 1; }

# return to repo root
cd ..

echo "=== CI: done ==="
exit 0