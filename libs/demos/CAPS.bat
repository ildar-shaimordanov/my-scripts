@echo off

setlocal

set getoptions=help
set getoptions_autohelp=1
call :GetOptions %*
if defined getoptions_exit (
    endlocal
    goto :EOF
)

set caps=

if defined opts.u (
    if defined opts.i (
        set caps=lcase
    ) else (
        set caps=ucase
    )
) else if defined opts.l (
    if defined opts.i (
        set caps=ucase
    ) else (
        set caps=lcase
    )
) else if defined opts.uf (
    if defined opts.i (
        set caps=lfirst
    ) else (
        set caps=ufirst
    )
) else if defined opts.lf (
    if defined opts.i (
        set caps=ufirst
    ) else (
        set caps=lfirst
    )
) else (
    call :help

    endlocal
    goto :EOF
)

call :%caps% caps "%opts_1%"
echo.%caps%

endlocal
goto :EOF

:help
echo Turns a character case in the text.
echo.
echo %~n0 text /U^|/UF^|/L^|/LF [/i]
echo.
echo   text  Text to be transformed
echo   /U    To upper case
echo   /L    To lower case
echo   /UF   First character upper case
echo   /LF   First character lower case
echo   /I    Invert case
echo.
goto :EOF

