@echo off

if not defined WWW_HOME for %%f in ( "%~dp0..\libexec\WWW" ) do set "WWW_HOME=%%~ff"
if not exist "%WWW_HOME%" (
	echo:"%WWW_HOME%" not exist>&2
	exit /b 1
)

if /i "%~1" == "define" goto :EOF

for %%a in ( run start stop restart ) do (
	if /i "%~1" == "%%~a" (
		start "%%a - %WWW_HOME%" "%WWW_HOME%\etc\%%a.exe"
		goto :EOF
	)
)

if /i "%~1" == "status" (
	wmic process where "name like '%%apache%%' or name like '%%mysql%%'" get Name,ProcessID,CommandLine /value
	goto :EOF
)


echo:Usage:
echo:    %~n0 RUN^|START^|STOP^|RESTART^|STATUS^|DEFINE
echo:
echo:RUN^|START - start the server
echo:STOP       - stop the server
echo:STATUS     - check the status of processes
echo:DEFINE     - define WWW_HOME variable

