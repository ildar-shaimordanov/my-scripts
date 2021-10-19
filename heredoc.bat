:: http://forum.script-coding.com/viewtopic.php?pid=94390#p94390
@if not defined CMDCALLER @(
	(echo on & goto) 2>nul
	call set "CMDCALLER=%%~f0"
	call "%~f0" %*
	set "CMDCALLER="
)
@if /i "%CMDCALLER%" == "%%~f0" set "CMDCALLER="


@echo off

if defined CMDCALLER (
	call :heredoc %*
	goto :EOF
)


call :heredoc :HEREDOCHELP & goto :EOF
heredoc: attempt to embed the idea of heredoc to batch scripts.

There are few ways for using this solution:

1. call heredoc :LABEL & goto :LABEL
Calling the external script "heredoc.bat" passing the heredoc LABEL. 

2. call :heredoc :LABEL & goto :LABEL
Embed the subroutine ":heredoc" into yuor script.

NOTES:
Both LABEL and :LABEL forms are possible. Instead of "goto :LABEL" it is 
possible to use "goto" with another label, or "goto :EOF", or "exit /b".

Variables to be evaluated within the heredoc should be called in the 
delayed expansion style ^("^!var^!" rather than "%var%", for instance^).

Literal exclamation marks "^!" and carets "^^" must be escaped with a 
caret "^".

Additionally, parantheses "(" and ")" should be escaped, as well, if they 
are part of the heredoc content within parantheses of the script block.
:HEREDOCHELP


:: http://stackoverflow.com/a/15032476/3627676
:heredoc LABEL
setlocal enabledelayedexpansion
if not defined CMDCALLER set "CMDCALLER=%~f2"
if not defined CMDCALLER set "CMDCALLER=%~f0"
if exist "!CMDCALLER!\" (
	echo:Not a file: "!CMDCALLER!" >&2
	exit /b 1
)
if not exist "!CMDCALLER!" (
	echo:File not found: "!CMDCALLER!" >&2
	exit /b 1
)
set go=
for /f "delims=" %%A in ( '
	findstr /n "^" "%CMDCALLER%"
' ) do (
	set "line=%%A"
	set "line=!line:*:=!"

	if defined go (
		if /i "!line!" == "!go!" goto :EOF
		echo:!line!
	) else (
		rem delims are @ ( ) > & | TAB , ; = SPACE
		for /f "tokens=1-3 delims=@()>&|	,;= " %%i in ( "!line!" ) do (
			if /i "%%i %%j %%k" == "call :heredoc %1" set "go=%%k"
			if /i "%%i %%j %%k" == "call heredoc %1" set "go=%%k"
			if defined go if not "!go:~0,1!" == ":" set "go=:!go!"
		)
	)
)
goto :EOF
