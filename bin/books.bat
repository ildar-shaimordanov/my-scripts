@echo off

:: Initialize
setlocal enabledelayedexpansion

:: Get options
set getoptions_autohelp=1
set getoptions_help=books_help
set getoptions_name=books
call :getoptions %*
if defined getoptions_exit goto end_script

:: Fix non-numeric values
call :is_number "%books.1%" 1
if errorlevel 1 set books.1=1

call :is_number "%books.N%" "%books.1%"
if errorlevel 1 set books.N=1000

call :is_number "%books.D%" 4
if errorlevel 1 set books.D=40

:: Fix /D option as divided by 4 exactly
set /a books.R="%books.D% %% 4"
set /a books.D=%books.D%-%books.R%
if %books.R% gtr 0 if defined books.ceil set /a books.D=%books.D%+4
set books.R=

:: Calculate pages
for /l %%a in ( %books.1%, %books.D%, %books.N% ) do (
    set /a books.L=%%a+%books.D%-1
    echo %%a-!books.L!
)

:: Finalize
:end_script
endlocal
goto :EOF


:: Help page
:books_help
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

