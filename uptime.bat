@echo off

:: ========================================================================

setlocal

set "uptime_boot="
set "uptime_curr="

for /f "tokens=1,* delims==" %%a in ( '
	wmic OS GET LastBootUpTime^,LocalDateTime /VALUE
' ) do if /i "%%~a" == "LastBootUpTime" (
	call :get_ts "%%~b" uptime_boot
) else if /i "%%~a" == "LocalDateTime" (
	call :get_ts "%%~b" uptime_curr
)

set /a "uptime_diff=uptime_curr-uptime_boot"

call :get_datetime diff
call :get_datetime curr

echo: %uptime_curr_hh%:%uptime_curr_mm%:%uptime_curr_ss% up %uptime_diff_dd% days, %uptime_diff_hh%:%uptime_diff_mm%

goto :EOF

:: ========================================================================

:get_datetime
set /a "uptime_%~1_ss=uptime_%~1 %% 60"
set /a "uptime_%~1_mm=uptime_%~1 / 60 %% 60"
set /a "uptime_%~1_hh=uptime_%~1 / 60 / 60 %% 24"
set /a "uptime_%~1_dd=uptime_%~1 / 60 / 60 / 24"

call set "uptime_%~1_ss=0%%uptime_%~1_ss%%"
call set "uptime_%~1_mm=0%%uptime_%~1_mm%%"
call set "uptime_%~1_hh=0%%uptime_%~1_hh%%"

call set "uptime_%~1_ss=%%uptime_%~1_ss:~-2%%"
call set "uptime_%~1_mm=%%uptime_%~1_mm:~-2%%"
call set "uptime_%~1_hh=%%uptime_%~1_hh:~-2%%"

goto :EOF

:: ========================================================================

:: Borowed from https://stackoverflow.com/a/11128674/3627676

:: Convert date/time from YYYYMMDDhhmmss.SSSSSS+zzz to Unix timestamp

:: 20190523222121.762088+180
:: 20190801180759.901000+180
::           1         2
:: 0123456789012345678901234

:: Get the timestamp in UTC
:get_ts_utc

:: Get the timestamp in local time
:get_ts
setlocal

set "ts=%~1"

set /a "yy=10000%ts:~0,4% %% 10000, mm=100%ts:~4,2% %% 100, dd=100%ts:~6,2% %% 100"
set /a "dd=dd-2472663+1461*(yy+4800+(mm-14)/12)/4+367*(mm-2-(mm-14)/12*12)/12-3*((yy+4900+(mm-14)/12)/100)/4"

::set /a ss=(((1%ts:~8,2%*60)+1%ts:~10,2%)*60)+1%ts:~12,2%-366100-%ts:~21,1%((1%ts:~22,3%*60)-60000)
set /a "ss=(((1%ts:~8,2%*60)+1%ts:~10,2%)*60)+1%ts:~12,2%-366100"
if "%~0" == ":get_ts_utc" set /a "ss-=%ts:~21,1%((1%ts:~22,3%*60)-60000)"

set /a ss+=dd*86400

endlocal & if "%~2" neq "" (set %~2=%ss%) else echo %ss%
goto :EOF

:: ========================================================================

:: EOF
