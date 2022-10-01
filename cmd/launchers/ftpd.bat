@echo off

setlocal

set "FTP_HOME=%~dp0..\libexec\FTP"

set "FTP_PROC_NAME=FileZilla Server"
set "FTP_CTRL_NAME=FileZilla Server Interface"

set "FTP_PROC=%FTP_PROC_NAME%.exe"
set "FTP_CONF=%FTP_PROC_NAME%.xml"
set "FTP_CTRL=%FTP_CTRL_NAME%.exe"

if /i "%~1" == "start" call :prepare-dirs
if /i "%~1" == "compat-start" call :prepare-dirs

for %%a in ( install uninstall start stop ) do if /i "%~1" == "%%~a" (
	"%FTP_HOME%\%FTP_PROC%" /%%~a
	endlocal
	goto :EOF

)

for %%a in ( start stop ) do if /i "%~1" == "compat-%%~a" (
	start "" "%FTP_HOME%\%FTP_PROC%" /compat /%%~a
	endlocal
	goto :EOF

)

if /i "%~1" == "status" (
	echo:Service
	echo:
	wmic Service WHERE "Name = '%FTP_PROC_NAME%'" get Name,State /value | findstr "."
	echo:
	echo:Process
	echo:
	wmic Process WHERE "Name = '%FTP_PROC%'" get Name,CommandLine,ProcessId,SessionId /value | findstr "."
	rem tasklist /fi "IMAGENAME EQ %FTP_PROC%" /fo list
	endlocal
	goto :EOF
)

if /i "%~1" == "control" (
	start "" "%FTP_HOME%\%FTP_CTRL%"
	endlocal
	goto :EOF
)


:: More command line arguments
:: https://wiki.filezilla-project.org/Command-line_arguments_%28Server%29
echo:Usage:
echo:	%~n0 INSTALL ^| UNINSTALL
echo:	%~n0 START ^| STOP ^| COMPAT-START ^| COMPAT-STOP
echo:	%~n0 STATUS ^| CONTROL
echo:
echo:INSTALL		install or uninstall the service
echo:UNINSTALL
echo:START		start or stop the server as the service
echo:STOP
echo:COMPAT-START	start or stop the server as the application
echo:COMPAT-STOP
echo:STATUS		check the status of processes and services
echo:CONTROL		launch the controlling client

endlocal
goto :EOF


:prepare-dirs
for /f "tokens=2 delims==>" %%d in ( '
	findstr /i /r /c:"<Permission Dir=\".*\">" "%FTP_HOME%\%FTP_CONF%"
' ) do (
	if exist %%~dd if not exist %%d md %%d
)
goto :EOF

:: EOF
