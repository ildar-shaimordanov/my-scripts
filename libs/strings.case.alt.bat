:: Makes the first character uppercase while other lowercase
::
:: @param  string  The name of variable to store new value
:: @param  string  The input string
:ufirst
if "%~2" == "" (
	set %~1=
	goto :EOF
)

setlocal

set s_o=%~2

call :ucase s_1 "%s_o:~0,1%"
call :lcase s_n "%s_o:~1%"

set s_o=%s_1%%s_n%

endlocal && set %~1=%s_o%
goto :EOF


:: Makes the first character lowercase while other uppercase
::
:: @param  string  The name of variable to store new value
:: @param  string  The input string
:lfirst
if "%~2" == "" (
	set %~1=
	goto :EOF
)

setlocal

set s_o=%~2

call :lcase s_1 "%s_o:~0,1%"
call :ucase s_n "%s_o:~1%"

set s_o=%s_1%%s_n%

endlocal && set %~1=%s_o%
goto :EOF


:: Makes the whole string uppercase
::
:: @param  string  The name of variable to store new value
:: @param  string  The input string
:ucase
if "%~2" == "" (
	set %~1=
	goto :EOF
)

call :translate ULCASE "%~1" "%~2" 1
goto :EOF


:: Makes the whole string lowercase
::
:: @param  string  The name of variable to store new value
:: @param  string  The input string
:lcase
if "%~2" == "" (
	set %~1=
	goto :EOF
)

call :translate ULCASE "%~1" "%~2"
goto :EOF


:: Translates a string accordingly the user-defined translation table
:: The custom translation table is defined as the set of strings formatted like below:
:: :::NAME Char1 Char2
::
:: Using the following table
:: ::: ULCASE A a
:: . . .
:: ::: ULCASE Z z
::
:: The code below will convert to lower case as "qwerty"
:: call :translate ULCASE var1 "QwErTy"
::
:: The code below will convert to upper case as "QWERTY"
:: call :translate ULCASE var1 "QwErTy" 1
::
:: @param  string  The name of tha translation table
:: @param  string  The name of variable to store new value
:: @param  string  The input string
:: @param  boolean The reverse direction of a translation
:translate
if "%~3" == "" (
	set %~2=
	goto :EOF
)

if not defined tr__%~1 (
	call :translate_loadtable
)

setlocal enabledelayedexpansion

set s_o=%~3
if "%~4" == "" (
	for /f "usebackq tokens=2,3 delims== " %%a in ( `set tr_%~1` ) do (
		set s_o=!s_o:%%~a=%%~b!
	)
) else (
	for /f "usebackq tokens=2,3 delims== " %%a in ( `set tr_%~1` ) do (
		set s_o=!s_o:%%~b=%%~a!
	)
)

endlocal && set %~2=%s_o%
goto :EOF


:: Reads all translation tables and load them to variables like tr_NAME_NN and tr__NAME
:: where NAME is the name of the appropriate table, NN is a number of variable.
:translate_loadtable
setlocal enabledelayedexpansion

set tr_c=0
set tr_s=endlocal
set tr_g=

for /f "usebackq tokens=2,3,4" %%a in ( `findstr /b ":::" "%~dpnx0"` ) do (
	if not defined tr_%%a (
		set tr_g=!tr_g!^&^&set tr__%%a=1
	)

	set /a tr_c+=1
	set tr_s=!tr_s!^&^&set tr_%%a_!tr_c!=%%b %%c
)

%tr_s%%tr_g%

goto :EOF


rem
rem USER-DEFINED TRANSLATION TABLE
rem
rem USE FORMAT STRICTLY AS BELOW:
rem ::: NAME UPPER lower
::: ULCASE A a
::: ULCASE B b
::: ULCASE C c
::: ULCASE D d
::: ULCASE E e
::: ULCASE F f
::: ULCASE G g
::: ULCASE H h
::: ULCASE I i
::: ULCASE J j
::: ULCASE K k
::: ULCASE L l
::: ULCASE M m
::: ULCASE N n
::: ULCASE O o
::: ULCASE P p
::: ULCASE Q q
::: ULCASE R r
::: ULCASE S s
::: ULCASE T t
::: ULCASE U u
::: ULCASE V v
::: ULCASE W w
::: ULCASE X x
::: ULCASE Y y
::: ULCASE Z z

