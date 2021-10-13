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
set "bom_val_EFBBBF=UTF-8"
set "bom_val_FEFF=UTF-16BE"
set "bom_val_FFFE=UTF-16LE"
set "bom_val_0000FEFF=UTF-32BE"
set "bom_val_FFFE0000=UTF-32LE"
set "bom_val_2B2F76=UTF-7"
set "bom_val_F7644C=UTF-1"
set "bom_val_DD736673=UTF-EBCDIC"
set "bom_val_0EFEFF=SCSU"
set "bom_val_FBEE28=BOCU-1"
set "bom_val_84319533=GB-18030"

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
for /f "tokens=1,2,3,4 delims=: " %%a in ( '
	fc /b "%bom_cmpfile%" "%~1" ^| findstr /n /r "^00*[0-3]"
' ) do (
	set /a bom_diff=%%a-%%b
	if !bom_diff! equ 2 set "bom_bytes=!bom_bytes!%%d"
)

set "bom_found="
for /l %%n in ( 8, -2, 4 ) do if not defined bom_found ^
for %%s in ( bom_val_!bom_bytes:~0^,%%n! ) do set "bom_found=!%%s!"

if defined bom_brief (
	if defined bom_found echo:%bom_found%
) else (
	echo:%~1: %bom_found%
)

shift /1
goto :bom_begin_loop

:: ========================================================================

:: EOF
