@echo off

setlocal

set "test_dir=%TEMP%"
::set "test_dir=."

echo:==== COMMON TESTS ====

::for /f %%x in ( '"%~dp0..\cmdize.bat" /L' ) do call :test_ext "%%~x"

echo:==== SPECIAL TESTS ====

call :test_ext .js
call :test_ext .js "/e cchakra"

call :test_ext .vbs
call :test_ext .vbs "/w"

call :test_ext .pl
call :test_ext .pl "/e cmdonly"

call :test_ext .py
call :test_ext .py "/e short"

goto :EOF

:: ========================================================================

:test_ext
echo:
echo:==== %~1 [%~2] ====
echo:

echo:==== Create file: z%~1
>"%test_dir%\z%~1" (
	for /f "tokens=1,* delims=:" %%a in ( 'findstr /i /b /l "::test%~1::" "%~f0"' ) do echo:%%b
)

echo:==== Cmdize z%~1
call "%~dp0..\cmdize.bat" %~2 "%test_dir%\z%~1"

echo:==== Display z.bat
findstr /n /r "^" "%test_dir%\z.bat"

echo:
:pause
echo:

goto :EOF

::test.vbs::	Option Explicit:Dim a:a = 1

::test.wsf::<?xml?>
::test.wsf::<job><script>WScript.Echo^("Hello"^)</script></job>

:: ========================================================================

:: EOF
