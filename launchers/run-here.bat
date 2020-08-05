@echo off

setlocal

if /i "%~1" == "" goto :run_help

:: Current user
:: HKEY_CURRENT_USER\Software\Classes\Drive\shell\<menu>\command
:: HKEY_CURRENT_USER\Software\Classes\Directory\shell\<menu>\command
:: HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\<menu>\command
set "run_rootkey=HKEY_CURRENT_USER"

:: All users
:: HKEY_LOCAL_MACHINE\Software\Classes\Drive\shell\<menu>\command
:: HKEY_LOCAL_MACHINE\Software\Classes\Directory\shell\<menu>\command
:: HKEY_LOCAL_MACHINE\Software\Classes\Directory\Background\shell\<menu>\command
if /i "%~1" == "/A" (
	set "run_rootkey=HKEY_LOCAL_MACHINE"
	shift
)

set "run_classkey=%run_rootkey%\Software\Classes"

:: /I, /U or /S
set "run_action=%~1"
shift

:: "menu"
set "run_menu=%~1"
shift

if not defined run_menu (
	>&2 echo:Menu not declared
	goto :run_help
)

set "run_subkey1=Drive Directory Directory\Background"

if /i "%run_action%" == "/I" goto :run_install
if /i "%run_action%" == "/U" goto :run_uninstall
if /i "%run_action%" == "/S" goto :run_show

goto :run_help


:run_install
if /i "%run_menu%" == "cmd" goto :run_forbidden

:: [/K iconfile]
set "run_iconfile="
if /i "%~1" == "/K" (
	set "run_iconfile=%~2"
	shift
	shift
)

:: [/NO-CHECK]
set "run_nocheck="
if /i "%~1" == "/NO-CHECK" (
	set "run_nocheck=1"
	shift
)

:: command
set "run_command=%~1"
shift

if not defined run_command (
	>&2 echo:Command not specified
	goto :run_help
)

if defined run_nocheck (
	set "run_progpath=%run_command%"
	goto :run_install_args
)

set "run_progpath="
for /f "tokens=*" %%c in ( "%run_command%" ) do (
	if not "%%~$PATH:c" == "" set "run_progpath=%%~$PATH:c"
	if exist "%%~fc" set "run_progpath=%%~fc"
)

if not defined run_progpath (
	>&2 echo:"%run_command%" not found
	goto :run_help
)

:run_install_args

:: [arguments] or "%V"
set "run_arguments="

:run_install_args_begin
if "%~1" == "" goto :run_install_args_end
	set "run_arguments=%run_arguments% %1"
	shift
goto :run_install_args_begin
:run_install_args_end

:: http://superuser.com/a/473602
:: http://www.robvanderwoude.com/ntstart.php
:: http://msdn.microsoft.com/en-us/library/windows/desktop/cc144101%28v=vs.85%29.aspx
if not defined run_arguments set "run_arguments= "%%V""

:: Escape quotes before enclosing within quotes
set "run_arguments=%run_arguments:"=\"%"

for %%s in ( %run_subkey1% ) do (
	reg add "%run_classkey%\%%s\shell\%run_menu%\command" /ve /d "\"%run_progpath%\"%run_arguments%" /f
)

if defined run_iconfile for %%s in ( %run_subkey1% ) do (
	reg add "%run_classkey%\%%s\shell\%run_menu%" /v Icon /t REG_SZ /d "%run_iconfile%" /f
)
goto :EOF


:run_uninstall
if /i "%run_menu%" == "cmd" goto :run_forbidden

for %%s in ( %run_subkey1% ) do (
	reg delete "%run_classkey%\%%s\shell\%run_menu%" /f
)
goto :EOF


:run_show
for %%s in ( %run_subkey1% ) do (
	reg query "%run_classkey%\%%s\shell\%run_menu%" /s
)
goto :EOF


:run_forbidden
>&2 echo:the operation over this element is forbidden.
goto :EOF


:run_help
echo:Open the command identified by the menu over the folder. 
echo:
echo:%~n0 [/A] /I "menu" [/K iconfile] [/NO-CHECK] command [arguments]
echo:%~n0 [/A] /U "menu"
echo:%~n0 [/A] /S "menu"
echo:
echo:menu       The menu item of the Windows Explorer context menu.
echo:command    The command to be executed on selecting the menu.
echo:arguments  Arguments to be passed to the command (otherwise %%V).
echo:/A         Apply for all users. By default, for the current user only.
echo:/I         Install the menu item.
echo:/U         Uninstall the existing item. 
echo:/S         Show the Registry entries if they exist.
echo:/K icon    Set the menu icon.
echo:/NO-CHECK  Do not check the path to the command when installing.
goto :EOF


