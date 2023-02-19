@echo off

setlocal

set "test_dir=%TEMP%"
::set "test_dir=."

for /f %%x in ( '"%~dp0..\cmdize.bat" /list' ) do call :test_ext "%%~x"

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
::test.wsf::<job><script>WScript.Echo("Hello")</script></job>

:: ========================================================================

:: EOF
