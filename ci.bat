@echo off
setlocal

echo === CI: start ===

rem Create build directory and enter it
if not exist build (
  mkdir build
)
cd build || (echo Failed to cd into build & pause & exit /b 1)

rem Configure project
echo --- cmake configure ---
cmake .. || (echo CMake configure failed & pause & exit /b 1)

rem Build project (use Release config on Windows)
echo --- build ---
if "%OS%"=="Windows_NT" (
  cmake --build . --config Release || (echo Build failed & pause & exit /b 1)
) else (
  cmake --build . || (echo Build failed & pause & exit /b 1)
)

rem Run tests with CTest (output on failure)
echo --- run tests (ctest) ---
ctest --output-on-failure || (echo Tests failed & pause & exit /b 1)

rem Return to repo root
cd .. || echo Warning: could not cd ..

echo === CI: done ===
pause
endlocal
exit /b 0