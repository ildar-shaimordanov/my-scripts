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
for /f "tokens=* delims=" %%a in ( '
	findstr /r "^__[0-9A-Za-z_][0-9A-Za-z_]*__$" "%~f0"
' ) do set "DATA_NAMES=!DATA_NAMES! %%a"
endlocal & set "DATA_NAMES=%DATA_NAMES%"

:extract_data_continue
set "DATA_THIS="
for /f "tokens=1,* delims=:" %%a in ( '
	findstr /n /r "^" "%~f0"
' ) do if "%%b" == "__%~1__" (
	set "DATA_THIS=%~1"
) else if defined DATA_THIS (
	for %%c in ( %DATA_NAMES% ) do if "%%b" == "%%c" goto :EOF
	setlocal disabledelayedexpansion
	if "%~2" == "" (
		echo:%%b
	) else (
		call %~2 "%%b"
	)
	endlocal
)
goto :EOF


__DATA__
there is data block
with 2 percents %%,
2 carets: ^ and ^
and 1 exclamation mark!
You can see all of them.

__WHO_AM_I__
Hello! I am "%USERNAME%"
My homedir: "%USERPROFILE%"
