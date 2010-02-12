:: Print a dirname for the specified argument with trailing "\"
::
:: @param  string  The argument to be parsed
:: @param  string  The variable to store the resulting value
:dirname
setlocal

call :parse_filename d1 d2 d3 d4 "%~1"
set d=%d1%%d2%

goto parse_filename_0


:: Print a filename only for the specified argument
::
:: @param  string  The argument to be parsed
:: @param  string  The variable to store the resulting value
:basename
setlocal

call :parse_filename d1 d2 d3 d4 "%~1"
set d=%d3%%d4%

:parse_filename_0
if "%~2" == "" (
	echo.%d%

	endlocal
	goto :EOF
)

endlocal && set %~2=%d%
goto :EOF


:: Stores al parts of a argument separately.
:: All arguments are mandatory.
::
:: @param  string  The variable for a drive
:: @param  string  The variable for a dirname
:: @param  string  The variable for a filename
:: @param  string  The variable for a extension
:: @param  string  The argument to be parsed
:parse_filename
setlocal

set p=%~5
if "%p:~-1%" == "\" (
	endlocal && call :parse_filename "%1" "%2" "%3" "%4" "%p:~0,-1%"
	goto :EOF
)

endlocal && set %~1=%~d5&& set %~2=%~p5&& set %~3=%~n5&& set %~4=%~x5
goto :EOF

