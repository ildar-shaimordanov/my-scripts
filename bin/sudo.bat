:: SUDO [command [options]]
::
:: Mimic to the unix command with the same name
:: Allow to run a command with the elevated privileges
@echo off

if "%~1" == "" (
	call "%~f0" cmd.exe "/s /k cd \"%cd%\""
	goto :EOF
)

PowerShell -Command Start-Process "%~1" -Args '%2 %3 %4 %5 %6 %7 %8 %9' -Verb RunAs
