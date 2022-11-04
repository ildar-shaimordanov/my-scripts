:: This file is the common wrapper over Rhino JavaScript tools. Create 
:: symbolic links next to this file as follows, to turn on the invocation 
:: for each of these tools:
::
:: Invoking Shell with java org.mozilla.javascript.tools.shell.Main
:: mklink rhino-shell.bat rhino.bat
::
:: Invoking Compiler with java org.mozilla.javascript.tools.jsc.Main
:: mklink rhino-jsc.bat rhino.bat
::
:: Invoking Debugger with java org.mozilla.javascript.tools.debugger.Main
:: mklink rhino-debugger.bat rhino.bat

@echo off

for %%f in ( 
	"%~dp0..\opt\rhino\lib\rhino*.jar" 
	"%~dp0..\opt\rhino\js.jar" 
) do if exist "%%~f" for %%t in (
		shell
		jsc
		debugger
) do if /i "%~n0" == "rhino-%%~t" (
	java -classpath "%%~f" org.mozilla.javascript.tools.%%~t.Main %*
	goto :EOF
)

echo:%~n0-{shell^|jsc^|debugger} [options]

:: ========================================================================

::EOF
