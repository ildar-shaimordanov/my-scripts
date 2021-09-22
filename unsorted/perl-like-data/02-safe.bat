@echo off

setlocal enabledelayedexpansion

call :extract_data WHO_AM_I :parse
call :extract_data DATA

goto :EOF


:parse
echo:%~1
goto :EOF


:extract_data
if defined DATA_NAMES goto :extract_data_continue

setlocal enabledelayedexpansion
set "DATA_NAMES="
for /f "tokens=3 delims=:" %%a in ( '
	findstr /r /c:"^goto :EOF & :[0-9A-Za-z_][0-9A-Za-z_]*$" "%~f0"
' ) do set "DATA_NAMES=!DATA_NAMES! %%a"
endlocal & set "DATA_NAMES=%DATA_NAMES%"

:extract_data_continue
set "DATA_THIS="
for /f "tokens=1,* delims=:" %%a in ( '
	findstr /n /r "^" "%~f0"
' ) do if "%%b" == "goto :EOF & :%~1" (
	set "DATA_THIS=%~1"
) else if defined DATA_THIS (
	for %%c in ( %DATA_NAMES% ) do if "%%b" == "goto :EOF & :%%c" goto :EOF
	setlocal disabledelayedexpansion
	if "%~2" == "" (
		echo:%%b
	) else (
		call %~2 "%%b"
	)
	endlocal
)
goto :EOF


goto :EOF & :DATA
there is data block
with 2 percents %%,
2 carets: ^ and ^
and 1 exclamation mark!
You can see all of them.

goto :EOF & :WHO_AM_I
Hello! I am "%USERNAME%"
My homedir: "%USERPROFILE%"
