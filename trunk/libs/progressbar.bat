:: Prints the simple progress bar within the DOS window or in the window title
::
:: @usage   call :progressbar INTEGER [ STRING ]
::
:: @param   INTEGER The length of the progress bar
:: @param   STRING  Optional non-empty value defines the another filling character
:progressbar
setlocal

set progressbar_c=%~2
if not defined progressbar_c (
    set progressbar_c=#
) else (
    set progressbar_c=%progressbar_c:~0,1%
)

set progressbar_s=
set /a progressbar_i=%~1

:progressbar_1
set progressbar_s=%progressbar_s%%progressbar_c%

if not defined progressbar_t (
    cls
    echo %progressbar_s%
) else (
    title %progressbar_s%
)

ping localhost -n 1 >nul

set /a progressbar_i-=1
if %progressbar_i% gtr 0 goto progressbar_1

endlocal
goto :EOF
