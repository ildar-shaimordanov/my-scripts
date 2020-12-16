
:: Mozilla Command Line Options
:: https://developer.mozilla.org/en-US/docs/Mozilla/Command_Line_Options
::
:: firefox -h | more

:: GUI application running string
set "pipecmd="%~dp0..\GUI\FirefoxPortable\App\Firefox\firefox.exe" -profile "%~dp0..\etc\misc\FirefoxPortable-Data\profile" %%*"

:: Set the extension to recognize the data type
::set "pipeext=.html"

:: Set the alternative tempfile saver
::set "pipetmpsave=findstr "$""
