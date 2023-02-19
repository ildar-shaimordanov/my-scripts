@echo off

setlocal

set "test_dir=%TEMP%"
::set "test_dir=."

::test.js::	WScript.Echo(WScript.ScriptFullName);
::test.js::	WScript.Echo( [
::test.js::		ScriptEngine(),
::test.js::		ScriptEngineMajorVersion(),
::test.js::		ScriptEngineMinorVersion(),
::test.js::		ScriptEngineBuildVersion()
::test.js::	].join('.'));
call :test_ext .js "/e :cscript"
call :test_ext .js "/e :cchakra"

::test.vbs::	Option Explicit
::test.vbs::
::test.vbs::	WScript.Echo WScript.ScriptFullName
::test.vbs::	WScript.Echo Join( Array( _
::test.vbs::		ScriptEngine, _
::test.vbs::		ScriptEngineMajorVersion, _
::test.vbs::		ScriptEngineMinorVersion, _
::test.vbs::		ScriptEngineBuildVersion _
::test.vbs::	), ".")
call :test_ext .vbs "/e :cscript"
call :test_ext .vbs "/e :wscript"

::test.wsf::<?xml version="1.0" ?>
::test.wsf::<package><job id="wsf+bat">
::test.wsf::<script language="javascript"><![CDATA[
::test.wsf::	WScript.Echo(WScript.ScriptFullName);
::test.wsf::	WScript.Echo( [
::test.wsf::		ScriptEngine(),
::test.wsf::		ScriptEngineMajorVersion(),
::test.wsf::		ScriptEngineMinorVersion(),
::test.wsf::		ScriptEngineBuildVersion()
::test.wsf::	].join('.'));
::test.wsf::]]></script>
::test.wsf::<script language="vbscript"><![CDATA[
::test.wsf::	Option Explicit
::test.wsf::
::test.wsf::	WScript.Echo WScript.ScriptFullName
::test.wsf::	WScript.Echo Join( Array( _
::test.wsf::		ScriptEngine, _
::test.wsf::		ScriptEngineMajorVersion, _
::test.wsf::		ScriptEngineMinorVersion, _
::test.wsf::		ScriptEngineBuildVersion _
::test.wsf::	), ".")
::test.wsf::]]></script>
::test.wsf::</job></package>
call :test_ext .wsf "/e :cscript"

::test.ps1::	"FILE: $Env:PS1_FILE"
::test.ps1::
::test.ps1::	$input | % {
::test.ps1::		"INPUT: [$_]"
::test.ps1::	}
::test.ps1::
::test.ps1::	"ARG#: $( $args.count )"
::test.ps1::	$args | % {
::test.ps1::		"ARGS: [$_]"
::test.ps1::	}
call :test_ext .ps1 "" "some arguments passed"

goto :EOF

:: ========================================================================

:test_ext
echo:
echo:==== %~1 [%~2] ====
echo:

echo:==== Create file: z%~1
>"%test_dir%\z%~1" (
	for /f "tokens=1,* delims=:" %%a in ( 'findstr /i /b /l "::test%~1::" "%~f0"' ) do echo:%%b
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

echo:
:pause
echo:

goto :EOF

:: ========================================================================

:: EOF
