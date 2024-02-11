@echo off

setlocal

for /f %%a in ('echo prompt $e^| cmd') do set "ESC=%%a"

call :colorer "Normal Foreground" 0 30 37
call :colorer "Bright Foreground" 1 30 37
call :colorer "Bright Foreground" 0 90 97
call :colorer "Normal Background" 0 40 47
call :colorer "Bright Background" 0 100 107

goto :EOF

:colorer
echo:%~1
for /l %%l in ( %~3, 1, %~4 ) do (
	echo:k=%~2; l=%%l: %ESC%[%~2;%%lmHello, world!%ESC%[0m
)
goto :EOF
