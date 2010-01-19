:: Estimates and returns the string value
::
:: @param  name
:: @param  string
:strlen
setlocal

set /a strlen=0
set strlen_str=%~2

:strlen_1
if not defined strlen_str goto strlen_2
set /a strlen+=1
set strlen_str=%strlen_str:~1%
goto strlen_1

:strlen_2
endlocal && set %~1=%strlen%
goto :EOF


:: Estimates and returns the string value
::
:: @param  name
:: @param  string
:str_len
if "%~2" == "" (
    set %~1=0
    goto :EOF
)

echo.%~2>"%TEMP%\%~n0.txt"
for /f %%a in ( "%TEMP%\%~n0.txt" ) do (
    set /a %~1=%%~za-2
    del "%%a"
)
goto :EOF


:: Repeats the input string N times
::
:: @param  name
:: @param  number
:: @param  string
:str_repeat
setlocal

set str=
set str_n=%~2
set str_c=%~3

:str_repeat_1
if %str_n% leq 0 goto str_repeat_2
set str=%str%%str_c%
set /a str_n-=1
goto str_repeat_1

:str_repeat_2
endlocal && set %~1=%str%
goto :EOF


:: Extract the first matching to a pattern
::
:: @param  String  variable name
:: @param  String  pattern
:: @param  String  pathname or/and filename
:: @param  String  (optional) arguments for FINDSTR
:substr
set %~1=
for /f "delims=\ tokens=1,*" %%a in ( "%~3" ) do (
    echo %%~a|findstr %~4 "%~2" > nul
    if errorlevel 1 (
        call :substr "%~1" "%~2" "%%~b" "%~4"
    ) else (
        set %~1=%%~a
    )
    if defined %~1 goto :EOF
)
goto :EOF

