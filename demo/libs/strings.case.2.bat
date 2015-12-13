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


::: RUS È shh
::: RUS Ë sh
::: RUS Á ch
::: RUS Â kh
::: RUS © jj
::: RUS Ò jo
::: RUS ¶ zh
::: RUS Ì eh
::: RUS Ó ju
::: RUS Ô ja
::: RUS Í ''
::: RUS Ï '
::: RUS † a
::: RUS ° b
::: RUS ¢ v
::: RUS £ g
::: RUS § d
::: RUS • e
::: RUS ß z
::: RUS ® i
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
::: RUS Ê c
::: RUS Î y

::: RUS ô Shh
::: RUS ò Sh 
::: RUS ó Ch 
::: RUS ï Kh 
::: RUS â Jj 
::: RUS  Jo 
::: RUS Ü Zh 
::: RUS ù Eh 
::: RUS û Ju 
::: RUS ü Ja 
::: RUS ö '' 
::: RUS ú '  
::: RUS Ä A  
::: RUS Å B  
::: RUS Ç V  
::: RUS É G  
::: RUS Ñ D  
::: RUS Ö E  
::: RUS á Z  
::: RUS à I  
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
::: RUS ñ C  
::: RUS õ Y  

