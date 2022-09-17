@echo off

if "%~1" == "/h" (
	echo:Usage: %~n0 [name]
	goto :EOF
)

for /f %%e in ( '"prompt $E & for %%e in (1) do rem"' ) do if "%~1" == "" (
	echo:%%e
) else (
	set "%~1=%%e"
)
