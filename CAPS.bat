@echo off


if "%~1" == "/?" goto help
if "%~2" == ""   goto help


for %%a in ( u l uf lf ) do (
    if /i "%~2" == "/%%~a" (
        setlocal enabledelayedexpansion

        call :%%a "%~1" "%~3"

        endlocal
        goto :EOF
    )
)


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


rem
rem Upper case
rem
:u
if /i "%~2" == "/I" goto :l_ui

:u_li
call :uppercase "%~1"
echo.%caps_t%

goto :EOF


rem
rem Lower case
rem
:l
if /i "%~2" == "/I" goto :u_li

:l_ui
call :lowercase "%~1"
echo.%caps_t%

goto :EOF


rem
rem First chacarter upper case
rem
:uf
if /i "%~2" == "/I" goto :lf_ufi

:uf_lfi
call :init "%~1"

call :uppercase "%caps_1%"
set caps_1=%caps_t%

call :lowercase "%caps_n%"
set caps_n=%caps_t%

echo.%caps_1%%caps_n%

goto :EOF


rem
rem First chacarter lower case
rem
:lf
if /i "%~2" == "/I" goto :uf_lfi

:lf_ufi
call :init "%~1"

call :lowercase "%caps_1%"
set caps_1=%caps_t%

call :uppercase "%caps_n%"
set caps_n=%caps_t%

echo.%caps_1%%caps_n%

goto :EOF


rem
rem Initialization
rem
:init
set caps_o=%~1
if not defined caps_o goto :EOF

set caps_1=%caps_o:~0,1%
set caps_n=%caps_o:~1%

goto :EOF

rem
rem Upper case, internally used
rem
:uppercase
set caps_t=%~1
call :translation_table 1

goto :EOF


rem
rem Lower case, internally used
rem
:lowercase
set caps_t=%~1
call :translation_table

goto :EOF


rem
rem
rem
:translation_table
if not defined caps_t goto :EOF

for /f "usebackq tokens=2,3" %%a in ( `findstr /b ":::" "%~dpnx0"` ) do (
    if "%~1" == "" (
        set caps_t=!caps_t:%%~a=%%~b!
    ) else (
        set caps_t=!caps_t:%%~b=%%~a!
    )
)
goto :EOF


rem
rem USER-DEFINED TRANSLATION TABLE
rem
rem USE FORMAT STRICTLY AS BELOW:
rem ::: UPPER lower
::: A a
::: B b
::: C c
::: D d
::: E e
::: F f
::: G g
::: H h
::: I i
::: J j
::: K k
::: L l
::: M m
::: N n
::: O o
::: P p
::: Q q
::: R r
::: S s
::: T t
::: U u
::: V v
::: W w
::: X x
::: Y y
::: Z z
