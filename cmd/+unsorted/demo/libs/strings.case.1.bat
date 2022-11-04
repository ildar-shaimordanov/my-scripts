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
goto :EOF


:: Additional cyrillic characters
::: ULCASE Ä †
::: ULCASE Å °
::: ULCASE Ç ¢
::: ULCASE É £
::: ULCASE Ñ §
::: ULCASE Ö •
::: ULCASE  Ò
::: ULCASE Ü ¶
::: ULCASE á ß
::: ULCASE à ®
::: ULCASE â ©
::: ULCASE ä ™
::: ULCASE ã ´
::: ULCASE å ¨
::: ULCASE ç ≠
::: ULCASE é Æ
::: ULCASE è Ø
::: ULCASE ê ‡
::: ULCASE ë ·
::: ULCASE í ‚
::: ULCASE ì „
::: ULCASE î ‰
::: ULCASE ï Â
::: ULCASE ñ Ê
::: ULCASE ó Á
::: ULCASE ò Ë
::: ULCASE ô È
::: ULCASE ö Í
::: ULCASE õ Î
::: ULCASE ú Ï
::: ULCASE ù Ì
::: ULCASE û Ó
::: ULCASE ü Ô

