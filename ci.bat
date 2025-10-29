@echo off
setlocal

echo === CI: start ===

REM Try to mark ci.sh executable in git index when running locally (skip in Actions)
where git >nul 2>&1
if %ERRORLEVEL%==0 (
  if not defined GITHUB_ACTIONS (
    git update-index --add --chmod=+x ci.sh 2>nul || echo Warning: could not set exec bit in git index
  )
)

rem Create build directory if missing
if not exist build (
  mkdir build
)

rem Enter build directory
pushd build

rem Configure project
echo --- cmake configure ---
cmake .. || (echo CMake configure failed & popd & exit /b 1)

rem Build project (use Release config on Windows)
echo --- build ---
cmake --build . --config Release || (echo Build failed & popd & exit /b 1)

rem Run tests with CTest (output on failure)
echo --- run tests (ctest) ---
ctest --output-on-failure || (echo Tests failed & popd & exit /b 1)

rem Return to repo root
popd

echo === CI: done ===
endlocal
exit /b 0