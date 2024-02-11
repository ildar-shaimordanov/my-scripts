@echo off

if "%~1" == "" (
	echo:Usage %~n0 FILE [/C]
	echo:/C means to create a copy
	goto :EOF
)

setlocal enabledelayedexpansion
set "ZC="
if /i "%~2" == "/c" set "ZC=-copy"
set "ZI=%~f1"
set "ZO=%~dpn1%ZC%%~x1.bat"
call :create-prolog "000" >"%ZO%"
for %%f in ( "%ZO%" ) do call :create-prolog %%~zf >"%ZO%"
copy /y /b "%ZO%"+"%ZI%" "%ZO%"
goto :EOF

:::: @echo:WSH.StdOut.Write(WSH.StdIn.ReadAll().slice(NNN))>"%TMP%\.js"&cscript/nologo "%TMP%\.js"<"%~f0">"%~dpn0"&exit/b

:create-prolog
for /f "tokens=1,*" %%a in ( 'findstr /r "^::::" "%~f0"' ) do (
	set "ZT=%%b"
	set "ZT=!ZT:NNN=%~1!"
	echo:!ZT!
rem	set /p "=!ZT!" <nul
)
goto :EOF
