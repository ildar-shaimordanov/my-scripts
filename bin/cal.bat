@echo off


setlocal


set getoptions_name=cal
set getoptions_help=help
set getoptions_autohelp=1
call :getoptions %*
if defined getoptions_exit goto EOS


if not defined cal_/u (
	set cal_year=%cal_1%
	set cal_month=%cal_2%
	set cal_date=%cal_3%
) else (
	if defined cal_3 (
		set cal_year=%cal_3%
		set cal_month=%cal_2%
		set cal_date=%cal_1%
	) else (
	if defined cal_2 (
		set cal_year=%cal_2%
		set cal_month=%cal_1%
		set cal_date=
	) else (
		set cal_year=%cal_1%
		set cal_month=
		set cal_date=
	))
)


call :now

if not defined cal_year (
	set cal_year=%now_year%
) else (
	call :is_number "%cal_year%" 1 9999
	if errorlevel 1 (
		echo.Illegal year value: use 1-9999
		goto error
	)
	set cal_def_year=1
)


if not defined cal_month (
	set cal_month=%now_month%
) else (
	call :is_number "%cal_month%" 1 12
	if errorlevel 1 (
		echo.Illegal month value: use 1-12
		goto error
	)
	set cal_def_month=1
)


call :set_leap
call :set_mday


if not defined cal_date (
	set cal_date=%now_date%
) else (
	call :is_number "%cal_date%" 1 %cal_mday%
	if errorlevel 1 (
		echo.Illegal day value: use 1-%cal_mday%
		goto error
	)
	set cal_def_date=1
)


set getoptions
set cal
set now


:EOS
endlocal
goto :EOF


:error
endlocal
exit /b 1


:set_leap
set /a cal_leap_004="%cal_year% %% 4"
set /a cal_leap_100="%cal_year% %% 100"
set /a cal_leap_400="%cal_year% %% 400"

if %cal_leap_004% == 0 if %cal_leap_100% neq 0 goto set_leap_1
if %cal_leap_400% == 0 goto set_leap_1

set cal_leap=0
goto :EOF

:set_leap_1
set cal_leap=1
goto :EOF


:set_mday
if %cal_month% == 4  goto set_mday_30
if %cal_month% == 6  goto set_mday_30
if %cal_month% == 9  goto set_mday_30
if %cal_month% == 11 goto set_mday_30

if %cal_month% == 2 (
	if not %cal_leap% == 1 set cal_mday=28
	if     %cal_leap% == 1 set cal_mday=29
	goto :EOF
)

set cal_mday=31
goto :EOF

:set_mday_30
set cal_mday=30
goto :EOF


:set_month
if %cal_month% ==  1 set cal_month_name=January
if %cal_month% ==  2 set cal_month_name=February
if %cal_month% ==  3 set cal_month_name=March
if %cal_month% ==  4 set cal_month_name=April
if %cal_month% ==  5 set cal_month_name=May
if %cal_month% ==  6 set cal_month_name=June
if %cal_month% ==  7 set cal_month_name=July
if %cal_month% ==  8 set cal_month_name=August
if %cal_month% ==  9 set cal_month_name=September
if %cal_month% == 10 set cal_month_name=October
if %cal_month% == 11 set cal_month_name=November
if %cal_month% == 12 set cal_month_name=December
goto :EOF


:help
echo.SYNOPSIS
echo.    %~n0    [OPTIONS] [year [month [date]]]
echo.    %~n0 /U [OPTIONS] [[[date] month] year]
echo.
echo.OPTIONS
echo.    /H - Display this help.
echo.    /1 - Display single month output. This is default.
echo.    /3 - Display prev/current/next month putput.
echo.    /S - Display Sunday as the first day of week. This is default.
echo.    /M - Display the Monday as the first day of week.
echo.    /J - Display Julian dates (days one-based, numbered from January 1).
echo.    /Y - Display a calendar for the current year.
echo.    /U - Define the order of date parts in the UNIX-like style.
goto :EOF

