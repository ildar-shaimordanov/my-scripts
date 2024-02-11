@setlocal&set S=WScript.Std&set "W=%TEMP%\%~n0.vbs"&set Z=186
@echo:Z=%Z%:%S%In.Skip Z:%S%Out.Write %S%In.Read(%~z0-Z)>"%W%"
@cscript//nologo "%W%"<"%~f0">"%~dpn0"&del/q "%W%"&exit/b
