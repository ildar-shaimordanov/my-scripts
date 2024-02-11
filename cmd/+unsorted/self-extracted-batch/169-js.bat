@set "W=%TEMP%\%~n0.js"
@echo:W=WScript;W.StdOut.Write(W.StdIn.Read(%~z0).replace(/(.+\r?\n){3}/,""))>"%W%"
@cscript//nologo "%W%"<"%~f0">"%~dpn0"&del/q "%W%"&exit/b
