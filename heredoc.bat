:: call heredoc :LABEL FILENAME
::
:: Internal use only. It's unlikely necessary to invoke the script this
:: way explicitly.
@if not "%~2" == "" (
	echo off
	call :heredoc %*
	goto :EOF
)

:: call heredoc :LABEL
::
:: Using the nude "goto" without a label causes the error. However
:: placing it within the parentheses we can catch this error and continue
:: executing the script. The sense of this trick is that "heredoc.bat"
:: escapes the context of the calling parent script, so the callee name
:: is still available via "%~f0" and the caller name is available now via
:: "%%~f0". This moment we can invoke ourselves the second time to pass
:: the caller name correctly. Because the execution context is owned by
:: the caller, the second invocation returns to the caller directly.
::
:: Initially this trick was discussed in this thread:
:: http://forum.script-coding.com/viewtopic.php?pid=94390#p94390
@if not "%~1" == "" (
	(echo on & goto) 2>nul
	for /f "tokens=*" %%f in ( 'call echo:%%~f0' ) do @call "%~f0" %* "%%~f"
)

:: call heredoc
::
:: Better use as a standalone script to learn the heredoc usage.
@echo off

call :heredoc :help & goto :EOF
It's attempt to apply the idea of heredoc in batch scripts.

USAGE:
    call [:]heredoc [:]LABEL & goto [:]LABEL
    ...
    :LABEL

NOTES:
The form "call heredoc" means calling the external "heredoc.bat" script.

The form "call :heredoc" means calling the internal ":heredoc" subroutine
placed within your script.

Both ":LABEL" or "LABEL" forms are possible. Instead of "goto [:]LABEL"
it's possible to use "goto" to an another label, or "goto :EOF" to quit
the script or subroutine, or "exit /b ..." for the same purpose. The
important thing is that you have to bypass the current heredoc block
to avoid an unexpected script behaviour due to execution of the heredoc
lines.

To expand variables within heredoc they must be used in the delayed
expansion style (^!var^! rather than %var%).

The exclamation mark "^!" must be escaped with the caret "^^" always. The
caret "^" itself can be escaped with the caret "^". Sometimes it is not
required.

Parentheses "(" and ")" must be escaped with the carets "^", if they
are part of the heredoc content within parentheses of the script block.
:help

:: ========================================================================

:: Another heredoc implementations are discussed in this thread:
:: https://stackoverflow.com/q/1015163/3627676
::
:: :: Everything below can be copied-and-pasted in to your scripts.

:heredoc [:]LABEL [FILENAME]
setlocal enabledelayedexpansion
set "HERE_FILE=%~f2"
if not defined HERE_FILE set "HERE_FILE=%~f0"
if exist "!HERE_FILE!\" (
	echo:Not a file: "!HERE_FILE!">&2
	exit /b 1
)
if not exist "!HERE_FILE!" (
	echo:File not found: "!HERE_FILE!">&2
	exit /b 1
)
if "%~1" == "" (
	echo:Empty label not permitted>&2
	exit /b 1
)
set HERE_LABEL=
for /f "delims=" %%A in ( '
	findstr /n "^" "%HERE_FILE%"
' ) do (
	set "HERE_LINE=%%A"
	set "HERE_LINE=!HERE_LINE:*:=!"

	if defined HERE_LABEL (
		if /i "!HERE_LINE!" == "!HERE_LABEL!" goto :EOF
		echo:!HERE_LINE!
	) else (
		rem delims are @ ( ) > & | TAB , ; = SPACE
		for /f "tokens=1-3 delims=@()>&|	,;= " %%i in (
			"!HERE_LINE!"
		) do for /f "tokens=1,2,3 delims=:" %%p in (
			"%%~i:%%~j:%%~k"
		) do (
			if /i "%%p:%%q:%%r" == "call:heredoc:%~1" set "HERE_LABEL=:%%r"
			if /i "%%p:%%q:%%r" == "call:heredoc%~1"  set "HERE_LABEL=:%%r"
		)
	)
)
if "%HERE_LABEL%" == ":"  set "HERE_LABEL="
if not defined HERE_LABEL set "HERE_LABEL=any label"
echo:Heredoc terminated abnormally: wanted %HERE_LABEL%>&2
goto :EOF
