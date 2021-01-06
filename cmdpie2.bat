::
::
::
::
::
::
::
::
:: This script still doesn't work properly
::
::
::
::
::
::
::
::
::
@echo off

if not "%~1" == "" goto :pie

call :pie BAKE "%~f0"
goto :EOF

:: ========================================================================

goto :PIE-PIECE-BAKE
NAME

  pie - the Plain, Impressive, Executable documentation format


DESCRIPTION

  Pie is a simple-in-use markup language used for writing documentation 
  for batch scripts in Windows DOS.

  Pie must have its own name. Thus, setting different names for each Pie
  it's possible to keep more than one Pie within one file.

  Pie may be stored as a entire piece. In the convenient purpose Pie may
  be spltted on few separate pieces (for example, each piece of Pie, being
  part of the documentation, explains a separate part of a code.

  Pie consists of few basic things: ordinary text, substitutions and 
  commands.

Ordinary text
  The majority of text in the documentation is the ordinary text blocks 
  like this one. You simply write it as is, without any markup.

Substitution
  It is any text surrounded with the percent characters "%" or the 
  replaceable variables in the form "%[format]name", where "name" is a 
  single letter, "format" is an option expanding the variable. For 
  details, see "FOR /?". Substitutions are used together with commands.

Command
  A command is the specially formatted string that turns some features. 
  Usually it is beginning or ending of Pie, calling some DOS commands or 
  echoing some text with substitution.

  All commands start with the double colon "::" followed by an identifier 
  and followed by some parameters separated with whitespaces.

There are commands:

::PIE-ECHO	"	goto :PIE-PIECE-pie_name-piece_name"
::PIE-ECHO	"	:PIE-PIECE-pie_name-piece_name"

The detailed explanation of each pie-command is given below.

::  goto :PIE-PIECE-<pie-name>-<piece-name>
::  :PIE-PIECE-<pie-name>-<piece-name>
  Each Pie is idenitified by its unique name as <pie-name>.

  If there is necessity to split the entire Pie on a few pieces and spread
  them within the file, the unique names for each piece is required as
  <piece-name>.


AUTHORS

  Copyright (C) 2016-2021 Ildar Shaimordanov

:PIE-PIECE-BAKE

:: ========================================================================

:pie
setlocal disabledelayedexpansion

set "pie-enabled="
set "pie-filename="
set "pie-openfile="
set "pie-comment="
set "pie-code="

for /f "delims=] tokens=1,*" %%a in ( '
	find /n /v "" "%~f2"
' ) do for /f "tokens=1,2,*" %%c in (
	"LINE %%b"
) do for /f "tokens=1,2,3,4,5 delims=-" %%f in (
	"LABEL-%%e"
) do for /f "tokens=1,2,3,4,5 delims=-" %%k in (
	"LABEL-%%d"
) do if not defined pie-enabled (
	if /i "%%d" == "goto" if "%%g-%%h-%%i" == ":PIE-PIECE-%~1" set "pie-enabled=1"
) else if "%%l-%%m-%%n" == ":PIE-PIECE-%~1" (
	set "pie-enabled="
	set "pie-filename="
	set "pie-openfile="
	set "pie-comment="
	set "pie-code="
) else if "%%d" == "::PIE-COMMENT-BEGIN" (
	set "pie-comment=1"
) else if "%%d" == "::PIE-COMMENT-END" (
	set "pie-comment="
) else if defined pie-comment (
	rem skip comment
) else if "%%d" == "::PIE-SETFILE" (
	set "pie-filename=%%~e"
	set "pie-openfile="
) else if "%%d" == "::PIE-OPENFILE" (
	set "pie-openfile=1"
) else if "%%d" == "::PIE-CREATEFILE" (
	set "pie-openfile=1"
	setlocal enabledelayedexpansion
	type nul >"!pie-filename!" || exit /b 1
	endlocal
) else if "%%d" == "::PIE-CODE-BEGIN" (
	set "pie-code=1"
) else if "%%d" == "::PIE-CODE-END" (
	set "pie-code="
) else if "%%d" == "::PIE-SET" (
	call set %%e
	if errorlevel 1 exit /b 1
) else (
	if defined pie-openfile (
		setlocal enabledelayedexpansion
		>>"!pie-filename!" (
			setlocal disabledelayedexpansion

			if "%%d" == "::PIE-ECHO" (
				call echo:%%~e
			) else if "%%d" == "::PIE-CALL" (
				call %%e
			) else (
				echo:%%b
			)

			endlocal
		) || exit /b 1
		endlocal
	) else (
		(
			if "%%d" == "::PIE-ECHO" (
				call echo:%%~e
			) else if "%%d" == "::PIE-CALL" (
				call %%e
			) else (
				echo:%%b
			)
		) || exit /b 1
	)
)

endlocal
goto :EOF

:: ========================================================================

:: EOF
