@echo off

if "%~1" == "" (
	echo:Detect BOM in a file.
	echo:Usage: %~n0 FILENAME
	goto :EOF
)

setlocal enabledelayedexpansion

set "bom_bytes="
set "bom_cmpfile=%TEMP%\bom_cmpfile"

set /p "=@@@@" <nul >"%bom_cmpfile%"

for /f "skip=1 tokens=1,2,3" %%a in ( 'fc /b "%bom_cmpfile%" "%~1"' ) do ^
if "%%a" leq "00000003:" set "bom_bytes=!bom_bytes!%%c"

del "%bom_cmpfile%"

:: ========================================================================

:: The following settings are based on information from the table
:: https://en.wikipedia.org/wiki/Byte_order_mark#Byte_order_marks_by_encoding
set "bom_EFBBBF=UTF-8"
set "bom_FEFF=UTF-16BE"
set "bom_FFFE=UTF-16LE"
set "bom_0000FEFF=UTF-32BE"
set "bom_FFFE0000=UTF-32LE"
set "bom_2B2F76=UTF-7"
set "bom_F7644C=UTF-1"
set "bom_DD736673=UTF-EBCDIC"
set "bom_0EFEFF=SCSU"
set "bom_FBEE28=BOCU-1"
set "bom_84319533=GB-18030"

:: ========================================================================

::set bom_

if defined bom_%bom_bytes:~0,4% call echo:%%bom_%bom_bytes:~0,4%%%
if defined bom_%bom_bytes:~0,6% call echo:%%bom_%bom_bytes:~0,6%%%
if defined bom_%bom_bytes%      call echo:%%bom_%bom_bytes%%%

:: ========================================================================

:: EOF
