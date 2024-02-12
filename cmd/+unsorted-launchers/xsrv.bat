@echo off

set "HOME=%TEA_HOME%\home"

for /d %%d in (
	"%~dp0..\libexec\xsrv"
	"%~dp0..\libexec\VcXsrv*"
	"%~dp0..\libexec\Xming*"
) do if exist "%%~d" for %%n in (
	vcxsrv Xming
) do if exist "%%~d\%%~n.exe" (
	start "" "%%~d\%%~n.exe" :0 -multiwindow -clipboard -unixkill
	goto :EOF
)

echo:X server not found>&2
