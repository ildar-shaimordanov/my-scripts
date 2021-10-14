<# :
@echo off
setlocal
set "PS1_ARGS=%*"
powershell -NoLogo -NoProfile -Command "$a=($Env:PS1_ARGS|sls -Pattern '\"(.*?)\"(?=\s|$)|(\S+)' -AllMatches).Matches;if($a.length){$a=@($a|%%{$_.value -replace '^\"','' -replace '\"$',''})}else{$a=@()};$i=$input;iex $('$input=$i;$args=$a;rv i,a;'+(gc \"%~f0\" -raw))"
rem powershell -NoLogo -NoProfile -Command "$a=($Env:PS1_ARGS|sls -Pattern '\"(.*?)\"(?=\s|$)|(\S+)' -AllMatches).Matches;if($a.length){$a=@($a|%%{$_.value -replace '^\"','' -replace '\"$',''})}else{$a=@()};$input|&{[ScriptBlock]::Create('rv a -scope script;'+(gc \"%~f0\" -raw)).Invoke($a)}"
goto :EOF
#>
$dir = "."

# Comment this line out to create files in the current directory
$dir = $env:TEMP

$str = "In math the Greek letter $([char]0x03C0) stands for 3.1415926"

$files = @( "ascii default oem utf8 utf32 unicode bigendianunicode".Split(" ") | % {
	$file = "$dir\z-$_.txt"
	Write-Output $str | Out-File -Encoding $_ $file
	$file
} )

"
Default usage:
"
(Get-Date).ToString('hh:mm:ss.ms')
& ..\file-detect-bom $files
(Get-Date).ToString('hh:mm:ss.ms')

"
Using the '-b' option:
"
(Get-Date).ToString('hh:mm:ss.ms')
& ..\file-detect-bom -b $files
(Get-Date).ToString('hh:mm:ss.ms')

# Comment this line out to prevent deletion of the files
Remove-Item $dir\z-*.txt
