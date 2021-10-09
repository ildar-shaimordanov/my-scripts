@echo off

setlocal

set "test_dir=%TEMP%"

echo:==== COMMON TESTS ====

for /f %%x in ( '"%~dp0..\cmdize.bat" /L' ) do call :test_ext "%%~x"

echo:==== SPECIAL TESTS ====

call :test_ext .js "/e node"
call :test_ext .pl "/e cmdonly"
call :test_ext .py "/e short"

del "%test_dir%\z.*"

goto :EOF

:test_ext
echo:
echo:==== %~1 [%~2] ====
echo:

> "%test_dir%\z%~1" (
	if "%~1" == ".vbs" echo:Option Explicit
	if "%~1" == ".wsf" echo:^<?xml?^>^<job^>^<script^>WScript.Echo^("Hello"^)^</script^>^</job^>
)

call "%~dp0..\cmdize.bat" %~2 "%test_dir%\z%~1"

more < "%test_dir%\z.bat"

echo:
:pause
echo:

goto :EOF
