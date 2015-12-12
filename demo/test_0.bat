@echo off

setlocal enabledelayedexpansion

set "if_stack=%~1"
set "if_needle=%~2"

call set "if_str=%%if_stack:%if_needle%=%%"

if     "!if_stack!" == "!if_needle!!if_str!" echo STARTS
if     "!if_stack!" == "!if_str!!if_needle!" echo ENDS
if not "!if_stack!" == "!if_str!"            echo CONTAINS

set if

endlocal
