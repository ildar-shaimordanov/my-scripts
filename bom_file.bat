::Usage: bom_file [OPTIONS] FILE...
::
::Detect the Byte Order Mark (BOM) in FILEs.
::
::  -b, --brief  Don't prepend filenames to output

@echo off

if "%~1" == "" (
	for /f "usebackq tokens=* delims=:" /f %%s in ( "%~f0" ) do (
		if /i "%%s" == "@echo off" goto :EOF
		echo:%%s
	)
	goto :EOF
)

setlocal enabledelayedexpansion

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

set "bom_brief="
if /i "%~1" == "-b"      set "bom_brief=1"
if /i "%~1" == "--brief" set "bom_brief=1"
if defined bom_brief shift /1

:: ========================================================================

set "bom_cmpfile=%TEMP%\bom_cmpfile"

set /p "=@@@@" <nul >"%bom_cmpfile%"

:: ========================================================================

:bom_begin_loop
if "%~1" == "" (
	del "%bom_cmpfile%"
	goto :EOF
)

set "bom_bytes="
for /f "skip=1 tokens=1,2,3" %%a in ( 'fc /b "%bom_cmpfile%" "%~1"' ) do ^
if "%%a" leq "00000003:" set "bom_bytes=!bom_bytes!%%c"

if not defined bom_brief set /p "=%~1: " <nul

if defined bom_%bom_bytes% (
	call echo:%%bom_%bom_bytes%%%
) else if defined bom_%bom_bytes:~0,6% (
	call echo:%%bom_%bom_bytes:~0,6%%%
) else if defined bom_%bom_bytes:~0,4% (
	call echo:%%bom_%bom_bytes:~0,4%%%
)

shift /1
goto :bom_begin_loop

:: ========================================================================

:: EOF
