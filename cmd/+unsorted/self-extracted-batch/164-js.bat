@set "W=%TEMP%\%~n0.js"
@echo:Z=164;W=WScript;I=W.StdIn;I.Skip(Z);W.StdOut.Write(I.Read(%~z0-Z))>"%W%"
@cscript//nologo "%W%"<"%~f0">"%~dpn0"&del/q "%W%"&exit/b
