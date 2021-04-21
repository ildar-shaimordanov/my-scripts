:: ========================================================================

:: GUI application running string

:: this is default browser
set pipecmd="%ProgramFiles%\Internet Explorer\iexplore.exe"

:: Mozilla Command Line Options
:: https://developer.mozilla.org/en-US/docs/Mozilla/Command_Line_Options
::
:: firefox -h | more
set "pipecmd="%~dp0..\GUI\FirefoxPortable\App\Firefox\firefox.exe" -profile "%~dp0..\etc\misc\FirefoxPortable-Data\profile" %%*"

:: ========================================================================

:: Set the extension to recognize the data type
::set "pipeext=.html"

:: ========================================================================

:: Set the alternative tempfile saver
::set "pipeslurp=findstr "$""

:: ========================================================================

:: EOF
