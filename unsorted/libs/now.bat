:: Disassemble and returns the time parts within the variables %now_XXX%
:: This routine depends on the locale settings
:now_datetime
for /f "tokens=1-7 delims=/-:., " %%1 in ( "%DATE% %TIME%" ) do (
    set now_year=%%3
    set now_month=%%2
    set now_date=%%1

    set now_hh=%%4
    set now_mm=%%5
    set now_ss=%%6
    set now_cc=%%7
)
goto :EOF


:: Returns the variables %now_XXX% with the formatted current date/time
::
:: @param  STRING  Optional, "/m" means to count each week from Monday,
::                 so Sunday is 7th day of week (by default, 0th day of week). 
::
:: http://forum.ru-board.com/topic.cgi?forum=5&amp;topic=25393&amp;start=347&amp;limit=1
:: The first line of the %TEMP%\rpt file looks like follows
::     MakeCAB Report: Mon Nov 02 23:46:37 2009
:now
makecab /d RptFileName="%TEMP%\rpt" /d InfFileName=nul /f nul >nul
for /f "usebackq tokens=3-9 delims=: " %%1 in ( "%TEMP%\rpt" ) do (
    set now_wday_name=%%1
    call :now_wday %%1
    if /i "%~1" == "/m" if /i "%%1" == "Sun" set now_wday=7

    set now_month_name=%%2
    call :now_month %%2

    set now_date=%%3

    set now_year=%%7

    set now_hh=%%4
    set now_mm=%%5
    set now_ss=%%6

    goto :EOF
)

:now_wday
set now_wday=0
for %%w in ( Sun Mon Tue Wed Thu Fri Sat Sun ) do (
    if /i "%1" == "%%w" goto :EOF
    set /a now_wday+=1
)
goto :EOF

:now_month
set now_month=0
for %%m in ( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ) do (
    set /a now_month+=1
    if /i "%1" == "%%m" goto :EOF
)
goto :EOF

