:: Populates the variable NAME with the the current working directory
::
:: @usage  call :tempname NAME
::
:: @param  string
:pwd
set %~1=%CD%

if "%CD:~-1%" == "\" (
	set %~1=%CD%
) else (
	set %~1=%CD%\
)

goto :EOF

