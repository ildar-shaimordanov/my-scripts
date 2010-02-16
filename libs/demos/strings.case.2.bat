@echo off

if "%~1" == "" (
    echo.Usage: %~n0 STRING
    goto :EOF
)

setlocal

call :rus2lat x3 "%~1"
call :lat2rus x4 "%~1"

echo.rus2lat=%x3%
echo.lat2rus=%x4%

endlocal
goto :EOF


:rus2lat
if "%~2" == "" (
	set %~1=
	goto :EOF
)

call :translate RUS "%~1" "%~2"
goto :EOF


:lat2rus
if "%~2" == "" (
	set %~1=
	goto :EOF
)

call :translate RUS "%~1" "%~2" 1
goto :EOF


::: RUS † a
::: RUS ° b
::: RUS ¢ v
::: RUS £ g
::: RUS § d
::: RUS • e
::: RUS Ò jo
::: RUS ¶ zh
::: RUS ß z
::: RUS ® i
::: RUS © jj
::: RUS ™ k
::: RUS ´ l
::: RUS ¨ m
::: RUS ≠ n
::: RUS Æ o
::: RUS Ø p
::: RUS ‡ r
::: RUS · s
::: RUS ‚ t
::: RUS „ u
::: RUS ‰ f
::: RUS Â kh
::: RUS Ê c
::: RUS Á ch
::: RUS Ë sh
::: RUS È shh
::: RUS Í ''
::: RUS Î y
::: RUS Ï '
::: RUS Ì eh
::: RUS Ó ju
::: RUS Ô ja

::: RUS Ä A
::: RUS Å B
::: RUS Ç V
::: RUS É G
::: RUS Ñ D
::: RUS Ö E
::: RUS  Jo
::: RUS Ü Zh
::: RUS á Z
::: RUS à I
::: RUS â Jj
::: RUS ä K
::: RUS ã L
::: RUS å M
::: RUS ç N
::: RUS é O
::: RUS è P
::: RUS ê R
::: RUS ë S
::: RUS í T
::: RUS ì U
::: RUS î F
::: RUS ï Kh
::: RUS ñ C
::: RUS ó Ch
::: RUS ò Sh
::: RUS ô Shh
::: RUS ö ''
::: RUS õ Y
::: RUS ú '
::: RUS ù Eh
::: RUS û Ju
::: RUS ü Ja

