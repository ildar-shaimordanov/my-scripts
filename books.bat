@echo off

:: Initialize
setlocal enabledelayedexpansion

:: Get options
set getoptions_autohelp=1
set getoptions_help=book_help
call :getoptions %*
if defined getoptions_exit goto end_script

:: Fix non-numeric values
set /a book_1=%opts_/1% 2>nul
set /a book_N=%opts_/n% 2>nul
set /a book_D=%opts_/d% 2>nul

if not defined book_1 set book_1=0
if not defined book_N set book_N=0
if not defined book_D set book_D=0

if %book_1% lss 1        set book_1=1
if %book_N% lss %book_1% set book_N=1000
if %book_D% lss 4        set book_D=40

:: Fix /D option as divided by 4 exactly
set /a book_D_R="%book_D% %% 4"
set /a book_D=%book_D%-%book_D_R%
if %book_D_R% gtr 0 if defined opts_/ceil set /a book_D=%book_D%+4
set book_D_R=

:: Calculate pages
for /l %%a in ( %book_1%, %book_D%, %book_N% ) do (
    set /a book_L=%%a+%book_D%-1
    echo %%a-!book_L!
)

:: Finalize
:end_script
endlocal
goto :EOF


:: Help page
:book_help
echo.Usage:
echo.    %~n0 [/1:NUM] [/N:NUM] [/D:NUM] [/CEIL]
echo.
echo.    /1    - The first page of a book
echo.    /N    - The last page of a book
echo.    /D    - The number of pages per one part. 
echo.            It is rounded to the nearest number 
echo.            divided by 4 but less than this one
echo.    /CEIL - Says to round /D to the nearest number 
echo.            divided by 4 but greater than this one
goto :EOF

