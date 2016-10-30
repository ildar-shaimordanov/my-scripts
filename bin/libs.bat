@echo off

if    "%~1" == ""   goto help
if /i "%~1" == "/h" goto help

if "%~dpnx0" == "%~dpnx2" (
    echo.Do not compile itself.
    exit /b 1
)

setlocal

:: This tool variables
set libs_path=%~dpn0
set libs_temp=%~dpn2~%~x2
set libs_back=%~dpn2.bak
set libs_make=
set libs_keep=

set libs_cmd_copy=copy /y /b
set libs_cmd_move=move /y

if not exist "%~2" (
    echo.File not found: "%~2".
    goto error
)

dir /ad "%libs_path%" >nul 2>nul
if errorlevel 1 (
    echo.Path not found: "%libs_path%".
    goto error
)

:: Collect the main script with provided libraries
%libs_cmd_copy% "%~2" "%libs_temp%" >nul

call :comment "goto :EOF">>"%libs_temp%"

for %%a in ( %~1 ) do (
    if /i "%%~a" == "/c" (
        rem Compile only, not execute
        set libs_make=1
    ) else (
    if /i "%%~a" == "/k" (
        rem Compile, execute and keep
        set libs_keep=1
    ) else (
    if /i "%%~a" == "/a" (
        rem Use all libraries
        for /f %%l in ( 'dir /b /a-d /on "%libs_path%\*.bat" "%libs_path%\*.cmd"' ) do (
            call :append "%%~l"
        )
    ) else (
    if exist "%libs_path%\%%~a.bat" (
        rem Looking for .BAT libraries
        call :append "%%~a.bat"
    ) else (
    if exist "%libs_path%\%%~a.cmd" (
        rem Looking for .CMD libraries
        call :append "%%~a.cmd"
    ) else (
        echo.Library not found: "%%~a".
        goto error
    )))))
)

:: Compile the main script and provided libraries and run by the command:
:: libs "... /C" ...
if defined libs_make (
    if exist "%libs_back%" (
        echo.File already exist: "%libs_back%".
        goto error
    )

    rem Store the original file under the backup name
    rem Save the new compiled file as the original one
    %libs_cmd_move% "%~2" "%libs_back%" && %libs_cmd_move% "%libs_temp%" "%~2"

    echo.
    echo."%~dpnx2" has been compiled with all provided libraries.
    echo.The original file has been backed up to the "%libs_back%".
    echo.

    goto EOS
)

:: Run the temporarily compiled script by the command:
:: libs "... [/K]" ...
set libs_args=

:loop
set libs_args=%libs_args% %3
shift
if not "%~3" == "" goto loop

call "%libs_temp%" %libs_args%


:EOS
if not defined libs_keep del "%libs_temp%" 2>nul
endlocal
goto :EOF


:error
if exist "%libs_temp%" del "%libs_temp%" 2>nul
endlocal
exit /b 1


:append
call :comment ":: %~n1">>"%libs_temp%"
%libs_cmd_copy% "%libs_temp%"+"%libs_path%\%~1" "%libs_temp%" >nul
goto :EOF


:comment
echo.
echo.:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo.:: %~n0 ^(c^) Copyright 2009 by Ildar Shaimordanov
echo.%~1
echo.
goto :EOF


:help
echo.Compiler ^(linker^) for batch files.
echo.%~n0 ^(c^) Copyright 2009 by Ildar Shaimordanov
echo.
echo.Usage:
echo.    %~n0 [/H]
echo.    %~n0 "LIBRARIES | /A [/C | /K]" PROGNAME [OPTIONS]
echo.
echo.  /A - Use all libraries
echo.  /C - Compile the main script and libraries to the whole file
echo.  /K - Keep a temporary file on a disk
goto :EOF

