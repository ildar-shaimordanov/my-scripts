@echo off

if "%~1" == "/?" goto :help
if "%~1" == "-?" goto :help

if /i "%~1" == "/h" goto :help
if /i "%~1" == "-h" goto :help


for %%p in ( powershell.exe wmic.exe ) do (
	if not "%%~$PATH:p" == "" goto :cmdpid.by.%%~np
)

>&2 echo:Unable to retrieve Process ID
exit /b 1


:: http://www.dostips.com/forum/viewtopic.php?p=38806#p38806
:cmdpid.by.powershell
for /f "tokens=*" %%p in ( '
	set "PPID=(Get-WmiObject Win32_Process -Filter ProcessId=$P).ParentProcessId" ^& ^
	call powershell -NoLogo -NoProfile -Command "$P = $pid; $P = %%PPID%%; %%PPID%%"
' ) do set CMDPID=%%p

goto :EOF


:: http://www.dostips.com/forum/viewtopic.php?p=38870#p38870
:cmdpid.by.wmic
setlocal disabledelayedexpansion

:cmdpid.by.wmic.getlock
set "cmdpid.lock=%TEMP%\%~nx0.%time::=.%.lock"
set "cmdpid.uid=%cmdpid.lock:\=:b%"
set "cmdpid.uid=%cmdpid.uid:,=:c%"
set "cmdpid.uid=%cmdpid.uid:'=:q%"
set "cmdpid.uid=%cmdpid.uid:_=:u%"

setlocal enableDelayedExpansion
set "cmdpid.uid=!cmdpid.uid:%%=:p!"
endlocal & set "cmdpid.uid=%cmdpid.uid%"

2>nul ( 9>"%cmdpid.lock%" (

for /f "skip=1 delims=" %%A in ( '
	wmic process where "Name='cmd.exe' and CommandLine like '%%<%cmdpid.uid%>%%'" get ParentProcessID
' ) do for %%B in ( %%A ) do set "CMDPID=%%B"
(call )

)) || goto :cmdpid.by.wmic.getlock

del "%cmdpid.lock%" 2>nul

endlocal & set "CMDPID=%CMDPID%"
goto :EOF


:help
echo:Calculates the Process ID of the currently running script or
echo:Command Prompt and stores in the environment variable CMDPID.
echo:
echo:Usage: %~n0
