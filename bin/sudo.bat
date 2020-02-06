:: SUDO [command [options]]
::
:: Mimic to the unix command with the same name
:: Allow to run a command with the elevated privileges
@echo off

setlocal

set "SUDO_HIDDEN="

if "%~1" == "" (
	call :sudo /s /k cd "%CD%"
	goto :EOF
)

for %%x in ( .bat .cmd ) do if /i "%~x1" == "%%x" (
	call :sudo /s /k cd "%CD%" "&&" %*
	goto :EOF
)

set "SUDO_HIDDEN=-WindowStyle Hidden"
call :sudo /c start /d "%CD%" %*

goto :EOF

:sudo
endlocal && powershell -Command Start-Process "cmd.exe" -Args '%*' %SUDO_HIDDEN% -Verb RunAs
goto :EOF
