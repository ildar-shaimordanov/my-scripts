@set S=WScript.Std&set "W=%TEMP%\%~n0.vbs"
@echo:Set R=New RegExp:R.Pattern="(.+\r?\n){3}":%S%Out.Write R.Replace(%S%In.Read(%~z0),E)>"%W%"
@cscript//nologo "%W%"<"%~f0">"%~dpn0"&del/q "%W%"&exit/b
