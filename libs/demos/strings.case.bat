@echo off

if "%~1" == "" (
    echo.Usage: %~n0 STRING
    goto :EOF
)

setlocal

call :ucase  var_uc "%~1"
call :lcase  var_lc "%~1"
call :ufirst var_uf "%~1"
call :lfirst var_lf "%~1"

set var

endlocal

