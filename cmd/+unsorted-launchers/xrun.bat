@echo off

set "HOME=%TEA_HOME%\home"

for /d %%d in (
	"%~dp0..\libexec\xsrv"
	"%~dp0..\libexec\VcXsrv*"
	"%~dp0..\libexec\Xming*"
) do if exist "%%~d" for %%m in (
	"vcxsrv    :0 -multiwindow -clipboard -unixkill"
	"Xming     :0 -multiwindow -clipboard -unixkill"
	"XLaunch   -run "%~dp0..\etc\xsrv\xsrv-multiwindow.xlaunch""
) do for /f "tokens=1,*" %%n in (
	"%%~m"
) do if exist "%%~d\%%~n.exe" (
	start "" "%%~d\%%~n.exe" %%~o
	goto :EOF
)

echo:X server not found>&2
