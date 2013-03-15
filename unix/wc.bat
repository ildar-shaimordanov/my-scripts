@echo off

::

setlocal enabledelayedexpansion
setlocal enableextensions


set wwc_debug=

set wwc_byte=
set wwc_line=
set wwc_word=
set wwc_args=


for %%a in ( %* ) do (
    if /i "%%~a" == "/?" (
        call :get_help
        goto end_script
    )

    if /i "%%~a" == "/d" (
        set wwc_debug=0
    ) else (
    if /i "%%~a" == "/c" (
        set wwc_byte=0
    ) else (
    if /i "%%~a" == "/l" (
        set wwc_line=0
    ) else (
    if /i "%%~a" == "/w" (
        set wwc_word=0
    ) else (
        set wwc_args=!wwc_args! "%%~a"
    ))))
)


if not defined wwc_byte if not defined wwc_line if not defined wwc_word (
    set wwc_byte=0
    set wwc_line=0
    set wwc_word=0
)


set wwc_t_byte=0
set wwc_t_line=0
set wwc_t_word=0
set wwc_t=0
for %%a in ( !wwc_args! ) do (
    if defined wwc_debug (
        echo.>&2
        echo [!DATE: =0! !TIME: =0!] Setting next file: "%%~a">&2
        echo.>&2
    )

    set /a wwc_t+=1

    set wwc_text=

    if defined wwc_line (
        call :count_lines_and_words "%%~a"

        set /a wwc_t_line+=!wwc_1_line!

        call :adjust_right !wwc_1_line!
        set wwc_1_line=!wwc_result!

        set wwc_text=!wwc_1_line!
    )

    if defined wwc_word (
        if not defined wwc_line (
            call :count_lines_and_words "%%~a"
        )

        set /a wwc_t_word+=!wwc_1_word!

        call :adjust_right !wwc_1_word!
        set wwc_1_word=!wwc_result!

        set wwc_text=!wwc_text! !wwc_1_word!
    )

    if defined wwc_byte (
        set wwc_1_byte=%%~za

        set /a wwc_t_byte+=!wwc_1_byte!

        call :adjust_right !wwc_1_byte!
        set wwc_1_byte=!wwc_result!

        set wwc_text=!wwc_text! !wwc_1_byte!
    )

    echo !wwc_text! %%~a
)


if !wwc_t! gtr 1 (
    set wwc_text=

    if defined wwc_line (
        call :adjust_right !wwc_t_line!
        set wwc_t_line=!wwc_result!

        set wwc_text=!wwc_t_line!
    )

    if defined wwc_word (
        call :adjust_right !wwc_t_word!
        set wwc_t_word=!wwc_result!

        set wwc_text=!wwc_text! !wwc_t_word!
    )

    if defined wwc_byte (
        call :adjust_right !wwc_t_byte!
        set wwc_t_byte=!wwc_result!

        set wwc_text=!wwc_text! !wwc_t_byte!
    )

    echo !wwc_text! total
)


:end_script
endlocal
goto :EOF


:count_lines_and_words
set wwc_1_line=0
set wwc_1_word=0

for /f "delims=[] tokens=1,*" %%b in ( 'find /n /v "" "%~1"' ) do (
    set /a wwc_1_line+=1

    call :count_words %%~c
)

set /a wwc_t_line+=!wwc_1_line!
goto :EOF


:count_words
if "%~1" == "" goto :EOF
    if defined wwc_debug echo.%1>&2
    set /a wwc_1_word+=1
    shift
goto count_words
goto :EOF


:adjust_right
rem The value should be adjusted to the right side within the field width of 7 characters
set wwc_result=       %~1
set wwc_result=!wwc_result:~-7!
goto :EOF


:get_help
echo Usage:
echo     %~n0 [OPTION]... [FILE]...
echo Print line, word, and byte counts for each FILE, and
echo a total line if more than one FILE is specified.
echo.
echo     /C       print the byte counts
echo     /L       print the line counts
echo     /W       print the word counts
goto :EOF

