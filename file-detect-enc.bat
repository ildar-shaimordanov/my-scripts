::Usage: file-detect-enc [OPTIONS] FILE...
::
::Detect type (encoding) of FILEs.
::
::  -b, --brief  Don't prepend filenames to output

@echo off

setlocal enabledelayedexpansion

set "enc_brief="
if /i "%~1" == "-b"      set "enc_brief=1"
if /i "%~1" == "--brief" set "enc_brief=1"
if defined enc_brief shift /1

if "%~1" == "" goto :print_usage

:: ========================================================================

:: The following settings are based on information from the table
:: https://en.wikipedia.org/wiki/Byte_order_mark#Byte_order_marks_by_encoding
set "enc_val_EFBBBF=UTF-8"
set "enc_val_FEFF=UTF-16BE"
set "enc_val_FFFE=UTF-16LE"
set "enc_val_0000FEFF=UTF-32BE"
set "enc_val_FFFE0000=UTF-32LE"
set "enc_val_2B2F76=UTF-7"
set "enc_val_F7644C=UTF-1"
set "enc_val_DD736673=UTF-EBCDIC"
set "enc_val_0EFEFF=SCSU"
set "enc_val_FBEE28=BOCU-1"
set "enc_val_84319533=GB-18030"

:: ========================================================================

set "enc_hexfile=%TEMP%\enc_hexfile"

:enc_begin_loop
if "%~1" == "" (
	del /f /q "%enc_hexfile%" 2>nul
	goto :EOF
)

for %%f in ( "%~1" ) do (
	call :detect_type "%%~f"

	if defined enc_brief (
		if defined enc_found echo:!enc_found!
	) else (
		echo:%%~f: !enc_found!
	)
)

shift /1
goto :enc_begin_loop

:: ========================================================================

:print_usage
for /f "usebackq tokens=* delims=:" %%s in ( "%~f0" ) do (
	if /i "%%s" == "@echo off" goto :EOF
	echo:%%s
)
goto :EOF

:: ========================================================================

:detect_type
set "enc_found="

set "enc_srcfile=%~1"

if not exist "%~1" (
	echo:File not found: "%~1">&2
	exit /b 1
)
if exist "%~1\" (
	set "enc_found=directory"
	goto :EOF
)
if %~z1 equ 0 (
	set "enc_found=empty"
	goto :EOF
)

:: https://stackoverflow.com/a/16238102/3627676
:: https://ss64.com/nt/certutil.html
:: https://www.dostips.com/forum/viewtopic.php?p=57918#p57918
:: https://docs.microsoft.com/en-gb/windows/win32/api/wincrypt/nf-wincrypt-cryptbinarytostringa
certutil -encodehex -f "%enc_srcfile%" "%enc_hexfile%" 4 >nul || (
	echo:Internal error: !errorlevel!>&2
	exit /b 1
)

set "enc_utf8_sequence="
set /a enc_utf8_require=0

set "enc_firstline=1"
for /f "usebackq delims=" %%s in ( "%enc_hexfile%" ) do (
	rem Most files (especially binaries) have in their beginning the
	rem magic number, or header, the group of bytes identifying the
	rem file type. Here we can analyze the header for magic number
	rem existence and quit immediately, if it's found. Otherwise,
	rem we continue analysis with the same line.
	if defined enc_firstline for /f "usebackq tokens=1-4" %%a in ( '%%s' ) do (
		set "enc_firstline="
		set "enc_bytes=%%a%%b%%c%%d"

		for /l %%n in ( 8, -2, 4 ) do if defined enc_found (
			goto :EOF
		) else for %%s in ( enc_val_!enc_bytes:~0^,%%n! ) do (
			set "enc_found=!%%s!"
		)
	)

	rem https://en.wikipedia.org/wiki/UTF-8#Encoding
	rem 0000-007f		00-7f	-----	-----	-----
	rem 0080-07ff		c0-df	80-bf	-----	-----
	rem 0800-ffff		e0-ef	80-bf	80-bf	-----
	rem 10000-10ffff	f0-f7	80-bf	80-bf	80-bf
	for %%b in ( %%s ) do if 0x%%b lss 0x80 (
		rem 00-7f
		set "enc_utf8_sequence="
		set /a enc_utf8_require=0
	) else if 0x%%b gtr 0xf7 (
		rem f8-ff
		set "enc_utf8_sequence="
		set /a enc_utf8_require=0
	) else (
		rem 80-f7
		set "enc_utf8_sequence=!enc_utf8_sequence!%%b"

		if 0x%%b geq 0xf0 (
			rem f0-f7
			set /a enc_utf8_require=3
		) else if 0x%%b geq 0xe0 (
			rem e0-ef
			set /a enc_utf8_require=2
		) else if 0x%%b geq 0xc0 (
			rem c0-df
			set /a enc_utf8_require=1
		) else if !enc_utf8_require! gtr 0 (
			rem 80-bf
			set /a enc_utf8_require-=1
			if !enc_utf8_require! equ 0 (
				set "enc_found=UTF-8"
				goto :EOF
			)
		)
	)
)
goto :EOF

:: ========================================================================

:: EOF
