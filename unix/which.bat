@echo off


if "%~1" == "" goto help


rem No wildcards, no drives, no paths
echo.%~1 | "%SystemRoot%\system32\findstr.exe" /v ": \ * ? , ; /" | "%SystemRoot%\system32\findstr.exe" "%~1" >nul
if errorlevel 1 goto help


rem Looking up DOSKEY macros
for /f "tokens=1* delims==" %%a in ( '"%SystemRoot%\system32\doskey.exe" /macros' ) do (
    if /i "%~1" == "%%a" (
        echo.-- DOSKEY macro
        goto :EOF
    )
)


rem Looking up builtins
rem This builtins list has been obtained by this script 
rem itself looking over the output of the 'HELP' command.
echo."%~1"|"%SystemRoot%\system32\find.exe" " " >nul
if errorlevel 1 (
    echo." assoc break call cd chdir cls color copy date del dir echo endlocal erase exit for ftype goto if md mkdir move path pause popd prompt pushd rd rem ren rename rmdir set setlocal shift start time title type ver verify vol "|"%SystemRoot%\system32\find.exe" " %~1 " >nul
    if not errorlevel 1 (
        echo.-- CMD internal
        goto :EOF
    )
)


setlocal 


rem Looking up the external executable command using %PATH% and %PATHEXT%.
call :lookup found "%~1"

if not defined found (
    echo.%~n0: no %~1 in ^(%PATH%^)

    endlocal
    exit /b 1
)

echo.%found%


:EOS
endlocal
goto :EOF


rem Looks up an external executable command using %PATH% and %PATHEXT%.
rem Stores the found full pathname to the provided variable.
rem
rem @param  variable name
rem @param  filename
:lookup
if not "%~x2" == "" goto lookup2

for %%c in ( "%PATHEXT:;=" "%" ) do (
    call :lookup2 "%~1" "%~2%%~c"
    if defined %~1 goto :EOF
)
goto :EOF

:lookup2
set %~1=%~$PATH:2
goto :EOF


:help
echo.Usage:
echo.    %~n0 PROGNAME
echo.
echo.  where PROGNAME should not consist of drive, paths or wildcards
goto :EOF

