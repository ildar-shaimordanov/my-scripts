@echo off

set CRONEDITOR=notepad

set CRONDIR=%~dp0..\opt\nnSoft\cron
set CRONRELOAD="%CRONDIR%\cron.exe" -reload
set CRONTAB="%CRONDIR%\cron.tab"

echo on

start /wait "" "%CRONEDITOR%" "%CRONTAB%"
start /wait "" "%CRONRELOAD%"
