<#

Generate the command for putting in to "cmdize.bat"
powershell -f cmdize-powershell.ps1

Generate the command for putting in to a standalone script
powershell -f cmdize-powershell.ps1 -standalone

Generate the command and emulate with a FILE
powershell -f cmdize-powershell.ps1 -emulateFile FILE [-isb] [FILE_ARGS]

#>

<#

"Param()" does't work in the powershell-in-batch hybrid mode. It means
that this script can't be hybridized (be embeded in to a batch file). To
resolve this issue it should be reworked to eliminate usage of "Param()",
or the script body should be placed into the function, or command line
arguments should be parsed and recognized manually without using the
builtin features.

#>
Param(
	[switch]$standalone = $False,

	[ValidateScript({ Test-Path $_ -PathType leaf })]
	[string]$emulateFile,

	[switch]$isb = $False
)

# =========================================================================

$executor = {
	# take command line arguments and parse them as we can
	$a = (
		$Env:PS1_ARGS | Select-String -Pattern '"(.*?)"(?=\s|$)|(\S+)' -AllMatches
	).Matches;
	$a = @( @( if ( $a.count ) { $a } ) | ForEach-Object {
		$_.value -Replace '^"', '' -Replace '"$', ''
	} );

	# read the batch file
	$f = Get-Content $Env:PS1_FILE -Raw;

	# invoke either scriptblock or expression
	if ( $Env:PS1_ISB ) {
		$input | &{ [ScriptBlock]::Create(
			'Remove-Variable f, a -Scope Script;' + $f
		).Invoke($a) }
	} else {
		$i = $input;
		Invoke-Expression $(
			'$input=$i;$args=$a;Remove-Variable i, f, a;' + $f
		)
	}
}

# =========================================================================

<#

The source of scriptblock above is minified and transformed to the command
being valid for putting it to batch files. The batch file syntax requires
that each percent character "%" in batch scripts should be doubled as
"%%". The "cmdize.bat" script itself is the batch file creating another
batch files, so each percent character must be quadrupled to be presented
as "%%%%". It's default script action. To change this default action use
the "-standalone" option. When the "-emulateFile" option is specified,
all multiple percent characters are squeezed up to the single one.

#>
$percent = if ( $standalone ) { '%%' } else { '%%%%' }

$minified = $executor.ToString()

$minified = $minified -Replace "```r?`n\s*", ''
$minified = $minified -Split "`r?`n"
$minified = $minified | Where-Object { $_ -notmatch '^\s*#' }
$minified = $minified -Join "`n"

#$minified = $minified -Replace "^#.*`r?`n", ''
$minified = $minified -Replace 'ForEach-Object', $percent
$minified = $minified -Replace 'Get-Content', 'gc'
$minified = $minified -Replace 'Invoke-Command', 'icm'
$minified = $minified -Replace 'Invoke-Expression', 'iex'
$minified = $minified -Replace 'Remove-Variable', 'rv'
$minified = $minified -Replace 'Select-String', 'sls'
$minified = $minified -Replace '"', '\"'
$minified = $minified -Replace '\s*([,=\|\+\{\}\(\)])\s*', '$1'
$minified = $minified -Replace "\s*`r?`n\s*", ''

# =========================================================================

if ( -not $emulateFile ) {
	"powershell -NoLogo -NoProfile -Command `"$minified`""
	exit
}

$Env:PS1_ISB = if ( $isb ) { '1' } else { '' }
$Env:PS1_FILE = $emulateFile
$Env:PS1_ARGS = ( $args | % { "`"$_`"" } ) -Join ' '

# Just to be sure in the transformation by this way only: %%%% -> %% -> %
$emulated = $minified -Replace '%%%%', '%%' -Replace '%%', '%'

powershell -NoLogo -NoProfile -Command $emulated

# =========================================================================

# EOF
