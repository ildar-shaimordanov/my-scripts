::
:: The tool was developed to enhance the functionality of `cmd.exe` 
:: similar to Unix-like shells. It is completely written as batch script 
:: and does npt add any external binaries. Nevertheless, it gives more 
:: functions and flexibility to `cmd.exe` and do maintainance little bit 
:: easier. 
::
:: In fact, this script is weak attempt to be closer to other shells - 
:: powerful, flexible and full-functional ones. Nevertheless, it works! 
:: This script can be found useful for those folks, who are not permitted 
:: to setup any other binaries excepting those applications permitted for 
:: installation. The better way is to use the other solutions like 
:: `Clink`, `ConEmu` or something else. 
::
@echo off

if /i "%~1" == "help" (
	findstr /b "::" "%~f0"
	goto :EOF
)
if /i "%~1" == "aliases" (
	call :cmd.aliases.readfile "%~2"
	goto :EOF
)
if /i "%~1" == "history" (
	call :cmd.history "%~2"
	goto :EOF
)
if /i "%~1" == "cd" (
	call :cmd.cd "%~2"
	goto :EOF
)
if /i "%~1" == "autorun" (
	call :cmd.autorun "%~2"
	goto :EOF
)
if not "%~1" == "" (
	>&2 echo:Unknown command "%~1".
	goto :EOF
)

::
:: # ENVIRONMENT VARIABLES
::
::
:: Behaviour of the script depends on some environment variables described 
:: below. Most of them have synonyms in unix and the same meaning. 
::
:: Uncomment a line if you want to turn on a feature supported by a 
:: variable. 
::
::
:: `CMD_ALIASFILE`
::
:: Define the name of the file of aliases or `DOSKEY` macros. 
::
if not defined CMD_ALIASFILE set "CMD_ALIASFILE=%~dpn0.aliases"
::
:: `CMD_HISTFILE`
::
:: Define the name of the file in which command history is saved. 
::
if not defined CMD_HISTFILE set "CMD_HISTFILE=%~dpn0.history"
::
:: `CMD_HISTFILESIZE`
::
:: Define the maximum number of lines in the history file. 
::
rem if not defined CMD_HISTFILESIZE set /a "CMD_HISTFILESIZE=500"
::
:: `CMD_HISTSIZE`
::
:: Define the maximum number of commands remembered by the buffer. 
:: By default `DOSKEY` stores `50` latest commands in its buffer. 
::
rem if not defined CMD_HISTSIZE set /a "CMD_HISTSIZE=50"
::
:: `CMD_HISTCONTROL`
::
:: A semicolon-separated list of values controlling how commands are saved 
:: in the history file. 
::
:: **Not implemented**
::
rem if not defined CMD_HISTCONTROL set "CMD_HISTCONTROL="
::
:: `CMD_HISTIGNORE`
::
:: A semicolon-separated list of ignore patterns used to decide which 
:: command lines should be saved in the history file. 
::
:: **Not implemented**
::
rem if not defined CMD_HISTIGNORE set "CMD_HISTIGNORE="

call :cmd.aliases.builtins
if exist "%CMD_ALIASFILE%" call :cmd.aliases.readfile "%CMD_ALIASFILE%"

if exist "%~dpn0.rc.bat" call "%~dpn0.rc.bat"

goto :EOF


:cmd.aliases.builtins
::
:: # ALIASES
::
::
:: `alias`
::
:: Display all aliases.
::
::
:: `alias name=text`
::
:: Define an alias with the name for one or more commands.
::
::
:: `alias -r [FILENAME]`
::
:: Read aliases from the specified file or `CMD_ALIASFILE`.
::
doskey alias=if "$1" == "" ( doskey /macros ) else if "$1" == "-r" ( "%~f0" aliases "$2" ) else ( doskey $* )
::
:: `unalias name`
::
:: Remove the alias specified by name from the list of defined aliases.
:: Run `DOSKEY /?` for more details.
::
doskey unalias=doskey $1=
::
:: `history`
::
:: Display or manipulate the history list for the actual session. 
:: Run `DOSKEY /?` for more details.
::
doskey history="%~f0" history $1
::
:: `cd`
::
:: Display or change working directory. 
::
doskey cd="%~f0" cd $1
::
:: `exit`
::
:: Exit the current command prompt; before exiting store the actual 
:: history list to the history file `CMD_HISTFILE` when it is configured. 
::
doskey exit=if not "$1" == "/?" ( "%~f0" history -w ) $T exit $*
::
:: `CTRL-D`
::
:: `CTRL-D` (`ASCII 04`, `EOT` or the *diamond* symbol) is useful shortcut 
:: for the `exit` command. Unlike Unix shells the `CTRL-D` keystroke 
:: doesn't close window immediately. In Windows command prompt you need to 
:: press the `ENTER` keystroke. 
::
doskey ="%~f0" history -w $T exit
goto :EOF


::
:: # ALIAS FILE
::
::
:: Alias file is the simple text file defining aliases or macros in the 
:: form `name=command` and can be loaded to the session by the prefedined 
:: alias `alias -r`.
::
:cmd.aliases.readfile
setlocal

if not "%~1" == "" set "CMD_ALIASFILE=%~1"

if not defined CMD_ALIASFILE (
	endlocal
	goto :EOF
)

if not exist "%CMD_ALIASFILE%" (
	>&2 echo:"%CMD_ALIASFILE%" not found.
	endlocal
	goto :EOF
)

set /a "CMD_HISTSIZE=CMD_HISTSIZE"
if %CMD_HISTSIZE% gtr 0 doskey /LISTSIZE="%CMD_HISTSIZE%"

doskey /MACROFILE="%CMD_ALIASFILE%"

endlocal
goto :EOF


::
:: # HISTORY
::
::
:: `history [options]`
::
::
:: ## Options
::
:cmd.history
if "%~1" == ""   goto :cmd.history.print
if "%~1" == "-c" goto :cmd.history.clear
if "%~1" == "-C" goto :cmd.history.uninstall
if "%~1" == "-w" goto :cmd.history.write

>&2 echo:Unsupported history option "%~1".
goto :EOF


::
:: `history`
::
:: Displays the history of the current session.
::
:cmd.history.print
doskey /HISTORY
goto :EOF


::
:: `history -c`
::
:: Clear the history list by setting the history size to 0 and reverting 
:: to the value defined in `CMD_HISTSIZE` or `50`, the default value. 
::
:cmd.history.clear
setlocal

set /a "CMD_HISTSIZE=CMD_HISTSIZE"
if %CMD_HISTSIZE% leq 0 set CMD_HISTSIZE=50
doskey /LISTSIZE=0
doskey /LISTSIZE=%CMD_HISTSIZE%

endlocal
goto :EOF


::
:: `history -C`
::
:: Install a new copy of `DOSKEY` and clear the history buffer. This way 
:: is less reliable and deprecated in usage because of possible loss of 
:: control over the command history. 
::
:cmd.history.uninstall
doskey /REINSTALL
goto :EOF


::
:: `history -w`
::
:: Write the current history to the file `CMD_HISTFILE` if it is defined. 
::
:cmd.history.write
if not defined CMD_HISTFILE goto :EOF

doskey /HISTORY >>"%CMD_HISTFILE%" || goto :EOF

if not defined CMD_HISTFILESIZE goto :EOF

setlocal 

set /a "CMD_HISTFILESIZE=CMD_HISTFILESIZE"
set /a "CMD_FILEPOS=0"

for /f %%f in ( ' 
	"%windir%\System32\more.exe" ^< "%CMD_HISTFILE%" ^| ^
	"%windir%\System32\find.exe" /v /c "" 
' ) do (
	set /a "CMD_FILEPOS=%%f-CMD_HISTFILESIZE"
)

if %CMD_FILEPOS% leq 0 (
	endlocal
	goto :EOF
)

more +%CMD_FILEPOS% "%CMD_HISTFILE%" >"%CMD_HISTFILE%~"
move /y "%CMD_HISTFILE%~" "%CMD_HISTFILE%"

endlocal
goto :EOF


::
:: # CHANGE DIRECTORY
::
::
:: `cd [options]`
::
::
:: Change the current directory can be performed by the following commands 
:: `CD` or `CHDIR`. To change both current directory and drive the option 
:: '/D' is required. To avoid certain typing of the option and simplify 
:: navigation between the current directory, previous one and user's home 
:: directory, the command is extended as follows.
::
:: See the following links for details
:: * http://ss64.com/nt/pushd.html
:: * http://ss64.com/nt/popd.html
:: * http://ss64.com/nt/cd.html
::
:: There is another way how to combine `cd`, `pushd` and `popd`. You can 
:: find it following by the link:
:: https://www.safaribooksonline.com/library/view/learning-the-bash/1565923472/ch04s05.html
::
::
:: `cd`
::
:: Display the current drive and directory.
::
::
:: `cd ~`
::
:: Change to the user's home directory.
::
::
:: `cd -`
::
:: Change to the previous directory. The previously visited directory is 
:: stored in the OLDCD variable. If the variable is not defined, no action 
:: happens. 
::
::
:: `cd path`
::
:: Change to the directory cpecified by the parameter.
::
:cmd.cd
if "%~1" == "-" if not defined OLDCD (
	>&2 echo:OLDCD not set
	goto :EOF
)

if "%~1" == "" (
	cd
	goto :EOF
)

setlocal

if "%~1" == "-" (
	set "NEWCD=%OLDCD%"
) else if "%~1" == "~" (
	set "NEWCD=%USERPROFILE%"
) else (
	set "NEWCD=%~1"
)

endlocal & set "OLDCD=%CD%" & cd /d "%NEWCD%"
goto :EOF


:cmd.autorun
setlocal

set "CMD_AUTORUN=HKCU\Software\Microsoft\Command Processor"

if "%~1" == "-s" (
	reg query  "%CMD_AUTORUN%" /v "AutoRun"
) else if "%~1" == "-i" (
	reg add    "%CMD_AUTORUN%" /v "AutoRun" /t REG_EXPAND_SZ /d "\"%~f0\"" /f
) else if "%~1" == "-u" (
	reg delete "%CMD_AUTORUN%" /v "AutoRun" /f
) else (
	>&2 echo:Unsupported autorun option "%~1".
)

endlocal
goto :EOF


::
:: # ADDITIONAL REFERENCES
::
:: * https://msdn.microsoft.com/ru-ru/library/windows/desktop/ee872121%28v=vs.85%29.aspx
:: * http://www.outsidethebox.ms/12669/
:: * http://www.transl-gunsmoker.ru/2010/09/11.html
::
