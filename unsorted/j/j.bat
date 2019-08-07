@echo off


rem *******************************************************
rem
rem This batch-script automates actions with Java
rem Usage is very simple:
rem Call this one within your batch script with defined 
rem arguments. Arguments can be found from this help.
rem
rem *******************************************************


if "%1" == "" goto HELP
if "%1" == "/?" goto HELP
if /i "%1" == "help" goto HELP

goto START


:HELP
echo.Java Helper Batch Script
echo.Copyright ^(c^) 2007-2009 by Ildar Shaimordanov
echo.
echo.Usage:
echo.    [CALL] J arguments
echo.
echo.J /?
echo.J HELP
echo.
echo.    Prints this help page.
echo.
echo.
echo.J CLASSPATH classpath
echo.
echo.    The argument specifies a path to be added to the existing CLASSPATH.
echo.    If the classpath is not specified the current CLASSPATH is clean.
echo.
echo.
echo.J JDK jdk
echo.
echo.    The argument specifies the path to the JDK, 
echo.    i.e. "C:\Program Files\Java\jdk1.5.0_11".
echo.    You should specify a location of specific JDK only.
echo.    Do not include path to the "bin" folder or 
echo.    full pathname of executable files.
echo.
echo.
echo.J PROJECT project
echo.
echo.    Creates the project paths in the currect folder.
echo.    You can specifies project as DOS/Unix/Java notation.
echo.
echo.
echo.J EDITOR editor
echo.
echo.    Sets the system name or the full pathname for the editor.
echo.    The default editor is the standard Windows Notepad.
echo.
echo.
echo.J EDIT class
echo.
echo.    Runs the specified editor with the fully qualified class 
echo.    as filename (without extension) to edit.
echo.
echo.
echo.J MAKE class
echo.
echo.    The argument specifies the fully qualified class name 
echo.    of the source file without extension to be compiled.
echo.
echo.
echo.J RUN class
echo.
echo.    The argument specifies the fully qualified class name 
echo.    of the binary file without extension to be executed.
echo.
echo.
echo.J JAR jarfile list
echo.
echo.    Compiles the "jarfile" from the specified a list of classes 
echo.    delimited by whitespace and listed within quotes.
echo.
echo.
echo.J CLEAR
echo.
echo.    Clears environment namespace from variables created by J script.
echo.    This is good practice to clear a working place after yourself.
echo.

goto STOP


rem **********************************************
rem
rem Paths to the JDK and source/binary files
rem

:START
set JSRCPATH=src
set JBINPATH=bin

if /i "%1" == "classpath" goto CLASSPATH
if /i "%1" == "jdk"       goto JDK
if /i "%1" == "project"   goto PROJECT
if /i "%1" == "editor"    goto EDITOR
if /i "%1" == "edit"      goto EDIT
if /i "%1" == "make"      goto MAKE
if /i "%1" == "run"       goto RUN
if /i "%1" == "jar"       goto JAR
if /i "%1" == "clear"     goto CLEAR
goto HELP


rem **********************************************
rem
rem Define CLASSPATH
rem Example:
rem [CALL] J CLASSPATH value
rem

:CLASSPATH
if     "%2" == "" set CLASSPATH=
if not "%2" == "" set CLASSPATH=%CLASSPATH%;%2

goto STOP


rem **********************************************
rem
rem Define path to the JDK
rem Example:
rem [CALL] J JDK "c:\j2sdk1.4.2_14"
rem

:JDK
set JJDKPATH=%~2

goto STOP


rem **********************************************
rem
rem Create new project at the current folder
rem Project name = path.to.the.project
rem Folder name  = path\to\the\project
rem Example:
rem [CALL] J PROJECT path.to.the.project
rem

:PROJECT
if "%~2" == "" goto project1
set J=%~2
set J=%J:/=\%
set J=%J:.=\%

:project1
md "%JBINPATH%"     2>nul
md "%JSRCPATH%\%J%" 2>nul

call :project2>jmake.bat

echo.****************************************************************
echo.
echo.The project had been created.
echo.
echo.Open and modify the "jmake.bat" scenario.
echo.Follow for comments within this file.
echo.
echo.****************************************************************

goto STOP

:project2
echo.@echo off
echo.
echo.
echo.rem This batch file is the wrapper that serve to simplify working with java files.
echo.rem There are some commands that should be modified befor start this scenario.
echo.rem Found lines containing "STUB" patterns and replace them with the appropriate values.
echo.rem You can remove optional commands and leave essential ones only (mandatory and recommended).
echo.
echo.
echo.rem MANDATORY
echo.rem It specifies the path of the JDK location.
echo.rem You HAVE TO replace "STUB" with the valid path of the JDK location.
echo.call j jdk "STUB"
echo.
echo.
echo.rem RECOMMENDED
echo.rem You can define additional libraries here
echo.call j classpath 
echo.
echo.
echo.rem OPTIONAL
echo.rem Compile of the files.
echo.rem Replace the "STUB" pattern with the valid filename of the compiled class.
echo.call j make "STUB" 
echo.
echo.
echo.rem OPTIONAL
echo.rem Runs of file.
echo.rem Replace the "STUB" pattern with the valid filename of the executed class.
echo.call j run "STUB" "%%*"
echo.
echo.
echo.rem OPTIONAL
echo.rem Creates JAR file.
echo.rem Replace the "STUB" pattern with the valid filename of the JAR.
echo.rem After the JAR file you can specify files that should be placed into JAR file.
echo.rem By default all files from the bin\ folder will be placed into JAR file.
echo.call j jar "STUB" 
echo.
echo.
echo.rem RECOMMENDED
echo.rem Clear global variables.
echo.call j clear

goto :EOF


rem **********************************************
rem
rem Sets the default editor for java files
rem Example:
rem [CALL] J EDITOR notepad
rem

:EDITOR
set JEDITOR=%~2

goto STOP


rem **********************************************
rem
rem Edit specified class
rem Source filename = path\to\the\class.java
rem Example:
rem [CALL] J EDIT path.to.the.class
rem

:EDIT
set J=%~2
set J=%J:/=\%
set J=%J:.=\%
set J=%J%.java

if "%JEDITOR%" == "" set JEDITOR=notepad
start %JEDITOR% "%CD%\%JSRCPATH%\%J%"

goto STOP


rem **********************************************
rem
rem Compile the class
rem Source filename = path\to\the\class.java
rem Example:
rem [CALL] J MAKE path.to.the.class [options]
rem

:MAKE
set J=%~2
set J=%J:/=\%
set J=%J:.=\%
set J=%J%.java

"%JJDKPATH%\bin\javac.exe" -d "%JBINPATH%" "%JSRCPATH%\%J%" %~3

goto STOP


rem **********************************************
rem
rem Execute the class
rem Destination class = path.to.the.class
rem Example:
rem [CALL] J RUN path.to.the.class [options]
rem

:RUN
set J=%~2
set J=%J:\=.%
set J=%J:/=.%

cd "%JBINPATH%"
"%JJDKPATH%\bin\java.exe" "%J%" %~3

goto STOP


rem **********************************************
rem
rem Create the JAR file for the bin\ folder
rem Example:
rem [CALL] J JAR jar_file.jar file1 file2 ...
rem

:JAR
set J=%~3
if "%J%" == ""  set J=.
if "%J%" == "." goto jar1
set J=%J:/=\%
set J=%J:.=\%
set J=%J:\class=.class%

:jar1
cd "%JBINPATH%"
if     exist ..\MANIFEST.MF "%JJDKPATH%\bin\jar.exe" -cvfm ..\%2 ..\MANIFEST.MF "%J%"
if not exist ..\MANIFEST.MF "%JJDKPATH%\bin\jar.exe" -cvf  ..\%2                "%J%"
cd ..

goto STOP


rem **********************************************
rem
rem Empty global variables
rem Example:
rem [CALL] J CLEAR
rem

:CLEAR
set JBINPATH=
set JSRCPATH=
set JJDKPATH=
set JEDITOR=


rem **********************************************
rem
rem Empty any temporary variables
rem

:STOP
set J=

