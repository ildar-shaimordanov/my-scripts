@echo off

for /f %%a in ('echo prompt $e^| cmd') do set "ESC=%%a"
