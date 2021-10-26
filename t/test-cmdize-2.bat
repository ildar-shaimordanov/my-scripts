@echo off

setlocal

set "test_dir=%TEMP%"

::.js::	WScript.Echo(WScript.ScriptFullName);
::.js::	
::.js::	WScript.Echo( [
::.js::		ScriptEngine(),
::.js::		ScriptEngineMajorVersion(),
::.js::		ScriptEngineMinorVersion(),
::.js::		ScriptEngineBuildVersion()
::.js::	].join('.'));
call :test_ext .js "/e cscript"
call :test_ext .js "/e cchakra"

::.vbs::	Option Explicit
::.vbs::	
::.vbs::	WScript.Echo WScript.ScriptFullName
::.vbs::	
::.vbs::	WScript.Echo Join( Array( _ 
::.vbs::		ScriptEngine, _
::.vbs::		ScriptEngineMajorVersion, _
::.vbs::		ScriptEngineMinorVersion, _
::.vbs::		ScriptEngineBuildVersion _
::.vbs::	), ".")
call :test_ext .vbs "/e cscript"
call :test_ext .vbs "/w /e cscript"

::.wsf::<?xml version="1.0" ?>
::.wsf::<package><job id="wsf+bat">
::.wsf::<script language="javascript"><![CDATA[
::.wsf::	
::.wsf::	WScript.Echo(WScript.ScriptFullName);
::.wsf::	
::.wsf::	WScript.Echo( [
::.wsf::		ScriptEngine(),
::.wsf::		ScriptEngineMajorVersion(),
::.wsf::		ScriptEngineMinorVersion(),
::.wsf::		ScriptEngineBuildVersion()
::.wsf::	].join('.'));
::.wsf::	
::.wsf::]]></script>
::.wsf::<script language="vbscript"><![CDATA[
::.wsf::	
::.wsf::	Option Explicit
::.wsf::	
::.wsf::	WScript.Echo WScript.ScriptFullName
::.wsf::	
::.wsf::	WScript.Echo Join( Array( _ 
::.wsf::		ScriptEngine, _
::.wsf::		ScriptEngineMajorVersion, _
::.wsf::		ScriptEngineMinorVersion, _
::.wsf::		ScriptEngineBuildVersion _
::.wsf::	), ".")
::.wsf::	
::.wsf::]]></script>
::.wsf::</job></package>
call :test_ext .wsf "/e cscript"

::.ps1::	$input | % {
::.ps1::		"INPUT: [$_]"
::.ps1::	}
::.ps1::	
::.ps1::	"ARG#: $( $args.count )"
::.ps1::	$args | % {
::.ps1::		"ARGS: [$_]"
::.ps1::	}
call :test_ext .ps1 "" "some arguments passed"

goto :EOF

:: ========================================================================

:test_ext
echo:
echo:==== %~1 [%~2] ====
echo:

echo:==== Create file: z%~1
>"%test_dir%\z%~1" (
	for /f "tokens=1,* delims=:" %%a in ( 'findstr /i /b /l "::%~1::" "%~f0"' ) do echo:%%b
)

echo:==== Cmdize z%~1
call "%~dp0..\cmdize.bat" %~2 "%test_dir%\z%~1"

echo:==== Display z.bat
findstr /n /r "^" "%test_dir%\z.bat"

echo:==== Execute z.bat
call "%test_dir%\z.bat"

if not "%~3" == "" (
	echo:==== Execute z.bat %~3
	call "%test_dir%\z.bat" %~3
)

pause
goto :EOF

:: ========================================================================

:: EOF
