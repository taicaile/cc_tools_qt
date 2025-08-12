@echo off
setlocal

REM ============================================================================
REM This script packages the build artifacts for a release.
REM It specifically packages the contents of the 'bin' subdirectory, which is
REM expected to contain the executable and all its runtime dependencies.
REM It expects the following environment variables to be set:
REM
REM - SOURCE_DIR:      The root installation directory (e.g., 'build/install').
REM - OUTPUT_FILENAME: The name of the final zip archive.
REM - WORKING_DIR:     The directory where packaging will take place and the
REM                    output zip will be created.
REM ============================================================================

if not defined SOURCE_DIR (
    echo "Error: SOURCE_DIR environment variable not set."
    exit /b 1
)
if not defined OUTPUT_FILENAME (
    echo "Error: OUTPUT_FILENAME environment variable not set."
    exit /b 1
)
if not defined WORKING_DIR (
    echo "Error: WORKING_DIR environment variable not set."
    exit /b 1
)

set "BIN_DIR=%SOURCE_DIR%\bin"
set "CUSTOM_PLUGINS_DIR=%SOURCE_DIR%\plugins"
set "PACKAGE_ROOT=%WORKING_DIR%\package_root"

if not exist "%BIN_DIR%" (
    echo "Error: Binary directory '%BIN_DIR%' not found."
    exit /b 1
)

echo "==> Preparing for packaging..."
echo "    Source Binaries: %BIN_DIR%"
echo "    Source Plugins: %CUSTOM_PLUGINS_DIR%"
echo "    Destination zip: %WORKING_DIR%\%OUTPUT_FILENAME%"

REM Clean up previous packaging directory if it exists
if exist "%PACKAGE_ROOT%" rmdir /s /q "%PACKAGE_ROOT%"
mkdir "%PACKAGE_ROOT%"

echo "==> Copying application and Qt dependencies..."
xcopy "%BIN_DIR%\\" "%PACKAGE_ROOT%\\" /E /I /Y /Q
if %errorlevel% neq 0 (
    echo "Error: Failed to copy binaries with xcopy."
    exit /b %errorlevel%
)

if exist "%CUSTOM_PLUGINS_DIR%" (
    echo "==> Copying custom application plugins..."
    xcopy "%CUSTOM_PLUGINS_DIR%\\" "%PACKAGE_ROOT%\plugins\\" /E /I /Y /Q
    if %errorlevel% neq 0 (
        echo "Error: Failed to copy custom plugins with xcopy."
        exit /b %errorlevel%
    )
)

echo "==> Creating zip archive..."
pushd "%PACKAGE_ROOT%"
7z a -tzip "%WORKING_DIR%\%OUTPUT_FILENAME%" ".\*" > nul
if %errorlevel% neq 0 (
    echo "Error: Failed to create zip archive with 7z."
    popd
    exit /b %errorlevel%
)
popd

echo "==> Cleaning up temporary package directory..."
rmdir /s /q "%PACKAGE_ROOT%"

echo "==> Packaging complete: %WORKING_DIR%\%OUTPUT_FILENAME%"
exit /b 0