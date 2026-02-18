:: CFR (Class File Reader) - Another Java Decompiler
:: https://github.com/leibnitz27/cfr
::
:: It's implemented entirely in Java 6 and able to decompile modern Java
:: features - including much of Java 9, 12, and 14.
::
:: This file is wrapper for CFR to simplify its invocation.
:: It looks for the latest Jar file in the same directory.
@echo off

for /f "tokens=*" %%f in ( '
	dir /o-n /b /s "%~dp0cfr-*.jar" 2^>nul
' ) do if "%~1" == "--version" for /f "tokens=*" %%s in ( '
	java -jar "%%~f" 2^>^&1
' ) do (
	echo:%%~s>&2
	goto :EOF
) else (
	java -jar "%%~f" %*
	goto :EOF
)

echo:No CFR jarfile found
exit /b 255
