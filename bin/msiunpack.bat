@echo off

if "%~1" == "" goto :help
if "%~2" == "" goto :help

setlocal

set "MSI_FILE=%~f1"
set "MSI_TARGET=%~f2"

msiexec /a "%MSI_FILE%" TARGETDIR="%MSI_TARGET%"

endlocal
goto :EOF

:help
echo:Usage: %~n0 msi-file target-dir
