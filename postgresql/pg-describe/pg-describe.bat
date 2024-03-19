:: Copyright (C) 2023, 2024 Ildar Shaimordanov
:: MIT License
@echo off

setlocal

if "%~1" == "" (
	echo:Usage: %~n0 XML_FILE [HTML_FILE]
	goto :EOF
)

set "xml_file=%~1"
set "html_file=%~2"

if not defined html_file set "html_file=rbs-arch-rbsdb.html"

>&2 echo:XML  : %xml_file%
>&2 echo:HTML : %html_file%

call wsx "%~dpn0.js" "%xml_file%" > "%html_file%"
