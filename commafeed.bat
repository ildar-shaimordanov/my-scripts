@echo off

setlocal

if /i "%~1" == "start" goto :start
if /i "%~1" == "stop" goto :stop
if /i "%~1" == "status" goto :status

echo:Usage: %~n0 start [console]^|stop^|status
goto :EOF

:: ========================================================================

:start
call :getpid
if defined pid goto :EOF

echo:Starting
if "%~2" == "console" (
	call :starter
) else (
	call :starter > nul
)

goto :EOF

:: ========================================================================

:starter
pushd "%~dp0"

set "jarfile=%~dp0commafeed.jar"
set "cfgfile=%~dp0config-win.yml"

start "Starting" /b ^
java -Djava.net.preferIPv4Stack=true -jar "%jarfile%" server "%cfgfile%"

popd
goto :EOF

:: ========================================================================

:stop
call :getpid
if not defined pid goto :EOF

echo:Stopping
taskkill /F /PID %pid%

goto :EOF

:: ========================================================================

:status
call :getpid
goto :EOF

:: ========================================================================

:getpid
set "pid="
for /f "tokens=1,* delims==" %%a in ( '
	wmic PROCESS WHERE ^
	"Caption='java.exe' AND CommandLine LIKE '%%commafeed.jar%%'" ^
	GET ProcessId^,CommandLine /VALUE
' ) do (
	call echo:%%~b
	if /i "%%~a" == "ProcessId" set "pid=%%~b"
)
goto :EOF

:: ========================================================================

:: EOF
