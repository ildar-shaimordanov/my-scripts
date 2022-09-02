@echo off

setlocal

echo.
echo %DATE%
echo %TIME%
echo.
echo.:now_datetime
call :now_datetime
echo.
set now
endlocal

setlocal

echo.
echo %DATE%
echo %TIME%
echo.
echo.:now
call :now "%~1"
echo.
set now
endlocal

goto :EOF

