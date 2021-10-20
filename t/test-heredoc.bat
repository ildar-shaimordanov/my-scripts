@echo off

call :print_html
call :print_text

goto :EOF

:print_html
echo:==== Print HTML
call :heredoc :HTML & goto :HTML
<html>
<body>
<h1>Hello, !USERNAME!^!</h1>
</body>
</html>
:HTML
goto :EOF

:print_text
echo:==== Print TEXT
call :heredoc :TEXT & goto :TEXT
USERNAME    = !USERNAME!
USERPROFILE = !USERPROFILE!

PWD  = !CD!
DATE = !DATE!
TIME = !TIME!
:TEXT

goto :EOF

:heredoc
call ..\heredoc.bat %*
goto :EOF
