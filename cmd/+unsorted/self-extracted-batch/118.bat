@echo:WSH.StdOut.Write(WSH.StdIn.ReadAll().slice(118))>"%TMP%\.js"&cscript/nologo "%TMP%\.js"<"%~f0">"%~dpn0"&exit/b
