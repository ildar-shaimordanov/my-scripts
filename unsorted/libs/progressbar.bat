:: Prints the simple progress bar within the DOS window or in the window title
::
:: @usage  call :progressbar INTEGER [ STRING ]
::
:: @param  INTEGER The length of the progress bar
:: @param  STRING  Optional non-empty value defines the another filling character
:: @see    http://groups.google.com/group/microsoft.public.win2000.cmdprompt.admin/msg/092e5cc12148ce2f?dmode=source
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

if not defined progressbar_t (
    (set /p progressbar_s=%progressbar_c%)<nul
) else (
    set progressbar_s=%progressbar_s%%progressbar_c%
    title %progressbar_s%
)

ping localhost -n 2 >nul

set /a progressbar_i-=1
if %progressbar_i% gtr 0 goto progressbar_1

endlocal
goto :EOF
