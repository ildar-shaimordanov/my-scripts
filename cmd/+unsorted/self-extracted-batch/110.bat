@echo:WSH.StdOut.Write(WSH.StdIn.ReadAll().slice(110))>.js&cscript/nologo .js<"%~f0">"%~dpn0"&del .js&exit/b
