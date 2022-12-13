@echo off

echo:PuTTY Portable: List session files:

if exist putty.conf (
	call :ppls putty.conf
) else (
	for /f "tokens=*" %%x in ( 'where putty' ) do call :ppls "%%~dpnx.conf"
)

goto :EOF

:ppls
for /f "usebackq tokens=1,* delims==" %%a in ( "%~f1" ) do ^
if "%%~a" == "sessions" if exist "%~dp1%%~b" dir /a-d /b "%~dp1%%~b"
goto :EOF
