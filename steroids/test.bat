::
:: Conditionals on steroids
::
::
:: DESCRIPTION
::
:: This script extends conditionals in Windows batch scenarios. Once 
:: included to your script it allows to construct the more powerful and 
:: flexible conditionals implemented on "steroids".
::
:: This script declares two "functions" implementing conditional operators 
:: for performing additional conditional expressions over files and 
:: strings. These functions exit with a status of (0) or (1) depending on 
:: the evaluations of an expression.
::
:: Expression could be in the standard form for the "IF" operator used in 
:: batch scenarios. For the details of the syntax read the help page by 
:: the "IF /?" command. 
::
:: The second form came from the Bash's "test" builtin command that 
:: extends capabilities of the standard operator in batches. In other 
:: words, there are steroids. 
::
::
:: USAGE
::
:: 1.  Run the following command to see this page
::
::     test HELP
::
:: 2.  Execute the following command to embed the functionality into  your 
::     script "filename"
::
::     test APPEND-TO filename
::
::     After that you can get these features as below:
::
::     call :if -f "%COMSPEC%" && echo FILE
::
:: 3.  These functions would be available on the whole system wherever you 
::     were. Put this script to some place on your system declared in the 
::     %PATH% variable and call the functions as it is shown below:
::
::     call test :if -f "%COMSPEC%" && echo FILE
::
@echo off &rem ::
setlocal enabledelayedexpansion & set "param=%~1" & if /i "!param!" == "HELP" ( for /f "tokens=* delims=:" %%a in ( 'findstr /b "::" "%~f0"' ) do (set "s=%%a" & if defined s (echo:!s:~1!) else (echo:)) ) & endlocal & exit /b 0
setlocal enabledelayedexpansion & set "param=%~1" & if /i "!param!" == "APPEND-TO" ( set "filename=%~2" & if "!filename!" == "" ( findstr /v "::" "%~f0" ) else ( findstr /v "::" "%~f0" >>"!filename!" ) ) & endlocal & exit /b 0
call %* &rem ::
goto :EOF &rem ::


::
:: if EXPR
:: unless EXPR
::
:: Evaluates conditional expressions and returns the status of (0) if the 
:: expression is true, otherwise (1). Returns the status of (2) if an 
:: invalid argumnts are given.
::

::
:: "UNLESS" works similar to "IF" but the sense of the test is reversed.
::
:unless
call :if %* && exit /b 1
if %ERRORLEVEL% == 2 exit /b 2
exit /b 0


::
:: To perform extended conditional operators this solution considers some 
:: arguments (starting with the "-" symbol) as special operators. To avoid 
:: confusion between those operators and normal arguments it's recommended 
:: wrap the comparable arguments within double quotes. Operators must be 
:: left unquoted anyway. So the following examples will work properly:
::
::     copy nul equ
::     call :if  -e  "equ"      && echo FILE EXISTS
::     call :if "-e"  equ  "-e" && echo EQUAL STRINGS
::
:if
setlocal enabledelayedexpansion


::
:: Extended file operators:
::
set if_opt=%1

:: -a FILE
::     True if file exists.
:: -b FILE
::     True if file is drive.
:: -c FILE
::     True if file is character device.
:: -d FILE
::     True if file is a directory. Similar to "-attr d".
:: -e FILE
::     True if file exists.
:: -f FILE
::     True if file exists and is a regular file.
:: -h FILE
::     True if file is a link. Similar to "-attr l".
:: -L FILE
::     True if file is a link. Similar to "-attr l".
:: -r FILE
::     True if file is read only. Similar to "-attr r".
:: -s FILE
::     True if file exists and is not empty.
:: -w FILE
::     True if the file is writable, i.e. not read only.
:: -x FILE
::     True if the file is executable.
for %%o in ( a b c d e f h L r s w x ) do if "!if_opt!" == "-%%o" (
	set "if_file=%~2"
	if "!if_opt!" == "-c" set "if_file=.\%~2:"

	if not exist !if_file! (
		endlocal
		exit /b 1
	)

	if "!if_opt!" == "-a" (
		endlocal
		exit /b 0
	)

	if "!if_opt!" == "-b" (
		if "%~dp2" == "%~f2" (
			endlocal
			exit /b 0
		)
		endlocal
		exit /b 1
	)

	if "!if_opt!" == "-c" (
		endlocal
		exit /b 0
	)

	if "!if_opt!" == "-d" (
		call :if -attr d !if_file!
		endlocal
		goto :EOF
	)

	if "!if_opt!" == "-e" (
		endlocal
		exit /b 0
	)

	if "!if_opt!" == "-f" (
		call :unless -attr d !if_file!
		endlocal
		goto :EOF
	)

	if "!if_opt!" == "-h" (
		call :if -attr l !if_file!
		endlocal
		goto :EOF
	)
	if "!if_opt!" == "-L" (
		call :if -attr l !if_file!
		endlocal
		goto :EOF
	)

	if "!if_opt!" == "-r" (
		call :if -attr r !if_file!
		endlocal
		goto :EOF
	)

	if "!if_opt!" == "-s" (
		if "%~z2" gtr 0 (
			endlocal
			exit /b 0
		)
		endlocal
		exit /b 1
	)

	if "!if_opt!" == "-w" (
		call :unless -attr r !if_file!
		endlocal
		goto :EOF
	)

	if "!if_opt!" == "-x" (
		call :unless -attr d !if_file! && for %%x in ( %PATHEXT% ) do (
			if /i "%%~x" == "%~x2" (
				endlocal
				exit /b 0
			)
		)
		endlocal
		exit /b 1
	)
)

:: -attr ATTR FILE
::     True if ATTR is set for FILE.
::
::     The following attributes can be recognized:
::     Attribute                    Expansion 
::     FILE_ATTRIBUTE_DIRECTORY     d-------- 
::     FILE_ATTRIBUTE_READONLY      -r------- 
::     FILE_ATTRIBUTE_ARCHIVE       --a------ 
::     FILE_ATTRIBUTE_HIDDEN        ---h----- 
::     FILE_ATTRIBUTE_SYSTEM        ----s---- 
::     FILE_ATTRIBUTE_COMPRESSED    -----c--- 
::     FILE_ATTRIBUTE_OFFLINE       ------o-- 
::     FILE_ATTRIBUTE_TEMPORARY     -------t- 
::     FILE_ATTRIBUTE_REPARSE_POINT --------l
::     FILE_ATTRIBUTE_NORMAL        --------- 
if "!if_opt!" == "-attr" (
	set "if_attr_abbr=%~2"
	for %%a in ( d r a h s c o t l ) do if "!if_attr_abbr!" == "%%a" (
		set "if_attr=%~a3"
		if defined if_attr if not "!if_attr!" == "!if_attr:%%a=-!" (
			endlocal
			exit /b 0
		)
		endlocal
		exit /b 1
	)

	echo:Unknown file attribute: "!if_attr_abbr!">&2
	endlocal
	exit /b 2
)

:: -path FILE
::     True if FILE is listed in the PATH environment variable.
if "!if_opt!" == "-path" (
	set "if_file=%~2"
	for %%f in ( "!if_file!" ) do if "%%~$PATH:f" == "" (
		endlocal
		exit /b 1
	)
	endlocal
	exit /b 0
)


::
:: Extended string operators:
::

:: -n STRING
::     True if STRING is not empty.
if "!if_opt!" == "-n" (
	set "if_str=%~2"
	if defined if_str (
		endlocal
		exit /b 0
	)
	endlocal
	exit /b 1
)

:: -z STRING
::     True if STRING is empty.
if "!if_opt!" == "-z" (
	set "if_str=%~2"
	if not defined if_str (
		endlocal
		exit /b 0
	)
	endlocal
	exit /b 1
)


if "!if_opt:~0,1!" == "-" (
	echo:"!if_opt!": Unary operator expected>&2
	endlocal
	exit /b 2
)


::
:: More file operators:
::
set if_opt=%2

:: FILE1 -nt FILE2
::     True if FILE1 is newer than FILE2 (according to modification time). 
::     This operator is depending on the user-defined settings or locales, 
::     that means that the result of this comparison cannot be considered 
::     as reliable. 
if "!if_opt!" == "-nt" (
	if "%~t1" gtr "%~t3" (
		endlocal
		exit /b 0
	)
	endlocal
	exit /b 1
)

:: FILE1 -ot FILE2
::     True if FILE1 is older than FILE2 (according to modification time). 
::     This operator is depending on the user-defined settings or locales, 
::     that means that the result of this comparison cannot be considered 
::     as reliable. 
if "!if_opt!" == "-ot" (
	if "%~t1" lss "%~t3" (
		endlocal
		exit /b 0
	)
	endlocal
	exit /b 1
)


::
:: More string operators:
::

:: STACK -contains NEEDLE
::     True if STACK contains NEEDLE.
:: STACK -starts NEEDLE
::     True if STACK starts with NEEDLE.
:: STACK -ends NEEDLE
::     True if STACK ends with NEEDLE.
for %%o in ( contains starts ends ) do if "!if_opt!" == "-%%o" (
	rem Skip estimation if one of STACK or NEEDLE is empty
	set "if_stack=%~1"
	set "if_needle=%~3"

	if not defined if_stack (
		endlocal
		exit /b 1
	)

	if not defined if_needle (
		endlocal
		exit /b 1
	)

	rem The length of STACK
	set "if_str=A!if_stack!"
	set /a "if_stack_len=0"
	for /l %%a in ( 12, -1, 0 ) do (
		set /a "if_stack_len|=1<<%%a"
		for %%b in ( !if_stack_len! ) do if "!if_str:~%%b,1!" == "" set /a "if_stack_len&=~1<<%%a"
	)

	rem The length of NEEDLE
	set "if_str=A!if_needle!"
	set /a "if_needle_len=0"
	for /l %%a in ( 12, -1, 0 ) do (
		set /a "if_needle_len|=1<<%%a"
		for %%b in ( !if_needle_len! ) do if "!if_str:~%%b,1!" == "" set /a "if_needle_len&=~1<<%%a"
	)

	if !if_stack_len! lss !if_needle_len! (
		endlocal
		exit /b 1
	)

	rem The length of the rest of STACK without NEEDLE
	set /a "if_rest_len=if_stack_len-if_needle_len"

	for %%k in ( !if_needle_len! ) do (
		if "!if_opt!" == "-starts" if "!if_stack:~0,%%k!" == "!if_needle!" (
			endlocal
			exit /b 0
		)
		if "!if_opt!" == "-ends" if "!if_stack:~-%%k!" == "!if_needle!" (
			endlocal
			exit /b 0
		)
		if "!if_opt!" == "-contains" for /l %%l in ( 0, 1, !if_rest_len! ) do (
			if "!if_stack:~%%l,%%k!" == "!if_needle!" (
				endlocal
				exit /b 0
			)
		)
	)

	endlocal
	exit /b 1
)


if "!if_opt:~0,1!" == "-" (
	echo:"!if_opt!": Binary operator expected>&2
	endlocal
	exit /b 2
)


::
:: Standard operators
::
:: IF [NOT] ERRORLEVEL number
:: IF [NOT] string1==string2
:: IF [NOT] EXIST filename
::
:: IF CMDEXTVERSION number
:: IF [NOT] DEFINED variable
:: IF [/I] string1 compare-op string2
::
:: NOT
::     Specifies that Windows should carry out the command only if the 
::     condition is false.
::
:: ERRORLEVEL number
::     Specifies a true condition if the last program run returned an exit 
::     code equal to or greater than the number specified.
::
:: string1==string2
::     Specifies a true condition if the specified text strings match. 
::
:: EXIST filename
::     Specifies a true condition if the specified filename exists.
::
:: CMDEXTVERSION number
::     The CMDEXTVERSION conditional works just like ERRORLEVEL, except it 
::     iscomparing against an internal version number associated with the 
::     Command Extensions.
::
:: DEFINED variable
::     The DEFINED conditional works just like EXIST except it takes an 
::     environment variable name and returns true if the environment 
::     variable is defined.
::
:: compare-op
::
:: EQU
::     Equal
:: NEQ
::     Not equal
:: LSS
::     Less than
:: LEQ
::     Less than or equal
:: GTR
::     Greater than
:: GEQ
::     Greater than or equal
::
:: /I
::     If specified, says to do case insensitive string compares. The /I 
::     switch can also be used on the string1==string2 form of IF. These 
::     comparisons are generic, in that if both string1 and string2 are 
::     both comprised of all numeric digits, then the strings are 
::     converted to numbers and a numeric comparison is performed. 
::
if %* (
	endlocal
	exit /b 0
)
endlocal
exit /b 1


::
:: EXAMPLES
::
:: %COMSPEC% is file
::     call :if -f "%COMSPEC%" && echo FILE
::
:: %COMSPEC% is not directory
::     call :unless -d "%COMSPEC%" && echo FILE
::
:: Do something if %STR% is not empty string
::     call :if -n "%STR%" && echo NOTEMPTY
::
:: Do something if %STR% is empty string
::     call :if -z "%STR%" && echo EMPTY
::
:: Do something depending on a file attribute
::     call :if -d "%FILE%" && (
::         echo DIR
::     ) || ( call :if -f "%FILE%" ) && (
::         echo FILE
::     ) || (
::         echo UNKNOWN
::     )
::
:: Full test example
::     set "f=%~1"
::     echo FILE: "%f%"
::     call test :if -a "%f%" && echo -a
::     call test :if -b "%f%" && echo -b
::     call test :if -c "%f%" && echo -c
::     call test :if -d "%f%" && echo -d
::     call test :if -e "%f%" && echo -e
::     call test :if -f "%f%" && echo -f
::     call test :if -h "%f%" && echo -h
::     call test :if -L "%f%" && echo -L
::     call test :if -r "%f%" && echo -r
::     call test :if -s "%f%" && echo -s
::     call test :if -w "%f%" && echo -w
::     call test :if -x "%f%" && echo -x
::
::
:: REFERENCES
::
:: BatchLibrary or how to include batch files
:: http://www.dostips.com/forum/viewtopic.php?p=6475#p6475
::
:: Testing If a Drive or Directory Exists from a Batch File
:: http://support.microsoft.com/kb/65994
::
:: How to check if parameter is file (or directory)?
:: http://www.dostips.com/forum/viewtopic.php?f=3&t=2464
::
:: Elegant idea that inspired this work (Russian forum)
:: http://forum.script-coding.com/viewtopic.php?pid=55000#p55000
::
:: :strLen - returns the length of a string 
:: http://www.dostips.com/DtTipsStringOperations.php#Function.strLen
::
:: The fastest method of the string length estimation (Russian forum)
:: http://forum.script-coding.com/viewtopic.php?pid=71000#p71000
::
:: Extended Attributes of a file
:: http://ss64.com/nt/syntax-args.html#attributes
::
::
:: COPYRIGHTS
::
:: Copyright (c) 2013, 2014 Ildar Shaimordanov
::

