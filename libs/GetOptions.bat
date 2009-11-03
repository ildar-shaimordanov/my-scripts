:: CMD/BAT GetOptions
:getoptions
if not defined getoptions_name set getoptions_name=opts
if not defined getoptions_help set getoptions_help=getoptions_help

set getoptions_i=0

set %getoptions_name%_total=0
set %getoptions_name%_count=0

:getoptions_loop_start

for /f "usebackq delims=: tokens=1,*" %%a in ( `echo %~1^|findstr "^/[a-z0-9_][a-z0-9_]*"` ) do (
    for %%h in ( /h /help /man ) do (
        if /i "%%~a" == "%%h" if defined getoptions_autohelp (
            call :%getoptions_help% %%~a
            set getoptions_exit=1
            goto :EOF
        )
    )

    if "%%~b" == "" (
        rem set %getoptions_name%_%%a=%%a
        call :getoptions_set "%getoptions_name%_%%a" "%%~a"
    ) else (
        rem set %getoptions_name%_%%a=%%b
        call :getoptions_set "%getoptions_name%_%%a" "%%~b"
    )

    goto getoptions_loop_continue
)

if "%~1" == "" goto getoptions_loop_break

set /a %getoptions_name%_count+=1

set /a getoptions_i+=1
rem set %getoptions_name%_%getoptions_i%=%1
call :getoptions_set "%getoptions_name%_%getoptions_i%" "%~1"

:getoptions_loop_continue
set /a %getoptions_name%_total+=1

shift
goto getoptions_loop_start
:getoptions_loop_break

set getoptions_i=

goto :EOF

:getoptions_set
set %~1=%~2
goto :EOF

:getoptions_help
echo.Usage:
echo.    %~n0 OPTIONS
echo.
echo.  where OPTIONS are in format like
echo.  VALUE or /NAME:VALUE
goto :EOF

