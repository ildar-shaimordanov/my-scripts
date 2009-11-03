@echo off

setlocal

rem failed - exact match, case-sensitive
call :substr SUBSTR users "C:\Documents and Settings\All Users\Start Menu"
echo result = %SUBSTR%

rem successful - case-insensitive - /i option
call :substr SUBSTR users "C:\Documents and Settings\All Users\Start Menu" /i
echo result = %SUBSTR%

rem successful - case-sensitive
call :substr SUBSTR Users "C:\Documents and Settings\All Users\Start Menu"
echo result = %SUBSTR%

rem failed - tested portion should start with the pattern - /b option
call :substr SUBSTR Users "C:\Documents and Settings\All Users\Start Menu" /b
echo result = %SUBSTR%

endlocal
goto :EOF

