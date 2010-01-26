:: Estimates and returns the string value.
:: The alternative algorithm is turned on 
:: when the third argument is passed. 
::
:: @usage  call :str_len NAME [STRING] [FLAG]
::
:: @param  name
:: @param  string
:: @param  string
:: @see    http://forum.script-coding.info/viewtopic.php?pid=32553#p32553
:: @see    http://groups.google.com/group/microsoft.public.win2000.cmdprompt.admin/msg/092e5cc12148ce2f?dmode=source
:str_len
if not "%~3" == "" goto str_len_2

setlocal

set /a str_len=0
set str_len_str=%~2

:str_len_1
if not defined str_len_str (
    endlocal && set %~1=%str_len%
    goto :EOF
)
set /a str_len+=1
set str_len_str=%str_len_str:~1%
goto str_len_1

:str_len_2
if "%~2" == "" (
    set %~1=0
    goto :EOF
)

(set /p %~1=%~2)<nul>"%TEMP%\%~n0.txt"

for /f %%a in ( "%TEMP%\%~n0.txt" ) do (
    set %~1=%%~za
    del "%%a" 2>nul
)
goto :EOF


:: Repeats the input string LENGTH times
::
:: @usage  call :str_repeat NAME LENGTH STRING
::
:: @param  name
:: @param  number
:: @param  string
:str_repeat
setlocal enabledelayedexpansion

set R=
set N=

set /a N=%~2 2>nul

if not defined N goto str_repeat_break
if %N% leq 0 goto str_repeat_break

set R=%~3

if not defined R goto str_repeat_break

call :str_len K "%R%"

set /a L=1
set /a N=%N%-1

:str_repeat_continue
if %N% leq 0 goto str_repeat_break

if %N% leq %L% (
	set /a M=%N% * %K%
	call :str_repeat_part
	set R=%R%!Q!
	goto str_repeat_break
)

set /a N=%N% - %L%
set R=%R%%R%
set /a L*=2
goto str_repeat_continue

:str_repeat_break
endlocal && set %~1=%R%
exit /b 0

:str_repeat_part
set Q=!R:~-%M%!
goto :EOF


:: Creates a random alfanumeric string with specified length
::
:: @usage  call :str_rnd NAME LENGTH
::
:: @param  name
:: @param  length
:: @see    http://forum.script-coding.info/viewtopic.php?pid=25716#p25716
:str_rnd
setlocal enabledelayedexpansion

set str_rnd_s=
set /a str_rnd_i=%~2

if not defined str_rnd_i (
	goto str_rnd_2
)

set str_rnd_c=0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz

:str_rnd_1
if %str_rnd_i% leq 0 goto str_rnd_2
set /a str_rnd_n=%RANDOM% %% 62
set str_rnd_s=%str_rnd_s%!str_rnd_c:~%str_rnd_n%,1!
set /a str_rnd_i-=1
goto str_rnd_1

:str_rnd_2
endlocal && set %1=%str_rnd_s%
goto :EOF


:: Extract the first matching to a pattern
::
:: @usage  call :subpath NAME PATTERN PATH [FLAGS]
::
:: @param  String  variable name
:: @param  String  pattern
:: @param  String  pathname or/and filename
:: @param  String  (optional) arguments for FINDSTR
:subpath
set %~1=
for /f "delims=\ tokens=1,*" %%a in ( "%~3" ) do (
    echo %%~a|findstr %~4 "%~2" > nul
    if errorlevel 1 (
        call :subpath "%~1" "%~2" "%%~b" "%~4"
    ) else (
        set %~1=%%~a
    )
    if defined %~1 goto :EOF
)
goto :EOF

