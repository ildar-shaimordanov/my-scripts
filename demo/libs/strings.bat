@echo off

setlocal

rem failed - exact match, case-sensitive
call :subpath SUBPATH users "C:\Documents and Settings\All Users\Start Menu"
echo result = %SUBPATH%

rem successful - case-insensitive - /i option
call :subpath SUBPATH users "C:\Documents and Settings\All Users\Start Menu" /i
echo result = %SUBPATH%

rem successful - case-sensitive
call :subpath SUBPATH Users "C:\Documents and Settings\All Users\Start Menu"
echo result = %SUBPATH%

rem failed - tested portion should start with the pattern - /b option
call :subpath SUBPATH Users "C:\Documents and Settings\All Users\Start Menu" /b
echo result = %SUBPATH%

endlocal
goto :EOF

