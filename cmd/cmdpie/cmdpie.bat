@echo off

if not "%~1" == "" goto :pie

call :pie BAKE "%~f0"
goto :EOF

:: ========================================================================

::PIE-BEGIN	BAKE
NAME

  pie - the Plain, Impressive, Executable documentation format


DESCRIPTION

  Pie is a simple-in-use markup language used for writing documentation 
  for batch scripts in Windows DOS.

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

::PIE-ECHO	"  ::PIE-BEGIN label"
::PIE-ECHO	"  ::PIE-END [STOP]"

::PIE-ECHO	"  ::PIE-ECHO text"
::PIE-ECHO	"  ::PIE-CALL command"
::PIE-ECHO	"  ::PIE-SET expression"

::PIE-ECHO	"  ::PIE-SETFILE "filename""
::PIE-ECHO	"  ::PIE-OPENFILE"
::PIE-ECHO	"  ::PIE-CREATEFILE"

::PIE-ECHO	"  ::PIE-COMMENT-BEGIN"
::PIE-ECHO	"  ::PIE-COMMENT-END"

::PIE-ECHO	"  ::PIE-CODE-BEGIN"
::PIE-ECHO	"  ::PIE-CODE-END"

The detailed explanation of each pie-command is given below.

::PIE-ECHO	"  ::PIE-BEGIN label"
::PIE-ECHO	"  ::PIE-END [STOP]"
  "::PIE-BEGIN" starts Pie itself. The mandatory "label" is used to 
  identify Pie. This allows to have more than one Pie within a single 
  file.

  "::PIE-END" ends the current Pie block. If the argument "STOP" is 
  specified, processing of the rest of input file will not be continued. 

::PIE-ECHO	"  ::PIE-ECHO text"
  "::PIE-ECHO" prints the specified "text". Any occurance of environment 
  or replaceable variables will be substituted. If the echoed text 
  contains the percent characters "%" they should be double to display.

::PIE-ECHO	"  ::PIE-CALL command"
  "::PIE-CALL" calls the specified command or commands. Substitution is 
  also available.

::PIE-ECHO	"  ::PIE-SET expression"
  "::PIE-SET" sets environment variable. The expression could have 
  the switches /A (for setting arithmetical expression) or /P (for setting 
  a variable to a string of input entered by the user). See for details 
  "SET /?". 

::PIE-ECHO	"  ::PIE-SETFILE "filename""
::PIE-ECHO	"  ::PIE-OPENFILE"
::PIE-ECHO	"  ::PIE-CREATEFILE"
  "::PIE-SETFILE" specifies a name of a file to write to. The filename can 
  be relative or absolute file path or can contain environment variables 
  that will be substituted too. The text it is expanded removing leading 
  and trailing quotes "" around the text. This gives ability to indent the 
  echoed text. 

  "::PIE-OPENFILE" and "::PIE-CREATEFILE" initialize writing to the file 
  specified by the command "::PIE-SETFILE". New data are appended to the 
  end of the file. The difference between these commands is that 

  "::PIE-CREATEFILE" truncates the file before the real writing. 

  Setting of the file and its opening are separated to enable additional 
  commands between them (for example, logging of an action before 
  performing it).

::PIE-ECHO	"  ::PIE-COMMENT-BEGIN"
::PIE-ECHO	"  ::PIE-COMMENT-END"
  "::PIE-COMMENT-BEGIN" starts and "::PIE-COMMENT-END" ends a block of 
  comments. This could be useful, if you need to escape printing of some 
  text but its removing from the file is unwanted.

::PIE-ECHO	"  ::PIE-CODE-BEGIN"
::PIE-ECHO	"  ::PIE-CODE-END"
  "::PIE-CODE-BEGIN" and "::PIE-CODE-END" are reserved for the future use. 
  By default they do not do anything significant.


AUTHORS

  Copyright (C) 2016, Ildar Shaimordanov

::PIE-END

:: ========================================================================

:pie
setlocal disabledelayedexpansion

set "pie-enabled="
set "pie-filename="
set "pie-openfile="
set "pie-comment="
set "pie-code="

for /f "delims=] tokens=1,*" %%r in ( '
	find /n /v "" "%~f2" 
' ) do for /f "tokens=1,2,*" %%a in (
	"LINE %%s"
) do if not defined pie-enabled (
	if "%%b %%~c" == "::PIE-BEGIN %~1" set "pie-enabled=1"
) else if "%%b" == "::PIE-END" (
	set "pie-enabled="
	set "pie-filename="
	set "pie-openfile="
	set "pie-comment="
	set "pie-code="
	if "%%~c" == "STOP" (
		endlocal
		goto :EOF
	)
) else if "%%b" == "::PIE-COMMENT-BEGIN" (
	set "pie-comment=1"
) else if "%%b" == "::PIE-COMMENT-END" (
	set "pie-comment="
) else if defined pie-comment (
	rem
) else if "%%b" == "::PIE-SETFILE" (
	call set "pie-filename=%%~c"
	set "pie-openfile="
) else if "%%b" == "::PIE-OPENFILE" (
	set "pie-openfile=1"
) else if "%%b" == "::PIE-CREATEFILE" (
	set "pie-openfile=1"
	setlocal enabledelayedexpansion
	type nul >"!pie-filename!" || exit /b 1
	endlocal
) else if "%%b" == "::PIE-CODE-BEGIN" (
	set "pie-code=1"
) else if "%%b" == "::PIE-CODE-END" (
	set "pie-code="
) else if "%%b" == "::PIE-SET" (
	call set %%c
	if errorlevel 1 exit /b 1
) else (
	if defined pie-openfile (
		setlocal enabledelayedexpansion
		>>"!pie-filename!" (
			setlocal disabledelayedexpansion

			if "%%b" == "::PIE-ECHO" (
				call echo:%%~c
			) else if "%%b" == "::PIE-CALL" (
				call %%c
			) else (
				echo:%%s
			)

			endlocal
		) || exit /b 1
		endlocal
	) else (
		(
			if "%%b" == "::PIE-ECHO" (
				call echo:%%~c
			) else if "%%b" == "::PIE-CALL" (
				call %%c
			) else (
				echo:%%s
			)
		) || exit /b 1
	)
)

endlocal
goto :EOF

:: ========================================================================

:: EOF
