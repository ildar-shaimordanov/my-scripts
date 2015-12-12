@echo off

setlocal

set IF_STACK=qwertyuiop
set IF_NEEDLE=qwertyuiop

call :if "%IF_STACK%" -starts "%IF_NEEDLE%" && (
	echo starts
)

call :if "%IF_STACK%" -ends "%IF_NEEDLE%" && (
	echo ends
)

call :if "%IF_STACK%" -contains "%IF_NEEDLE%" && (
	echo contains
)

endlocal
goto :EOF


:if
call ..\test :if %*
goto :EOF


:unless
call ..\test :unless %*
goto :EOF


