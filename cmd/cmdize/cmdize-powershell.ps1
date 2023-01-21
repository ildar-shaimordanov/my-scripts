<#

Generate the command for putting to "cmdize.bat"
powershell -ep bypass -f cmdize-powershell.ps1

Generate the command for putting to a standalone script
powershell -ep bypass -f cmdize-powershell.ps1 -standalone

Generate the command and emulate with a FILE
powershell -ep bypass -f cmdize-powershell.ps1 -emulateFile FILE [-isb] [FILE_ARGS]

#>

<#

"Param()" does't work in the powershell-in-batch hybrid mode. It means
that this script can't be hybridized (be embeded to a batch file). To
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

# Split by EOL and remove indentation; remove all one-line comments
$minified = $minified -Split "\s*`r?`n\s*"
$minified = $minified | Where-Object { $_ -NotMatch '^#' }

# Combine into one line
$minified = $minified -Join ""

# Prepare for valid one-line program
$minified = $minified -Replace '"', '\"'
$minified = $minified -Replace '\s*([,=\|\+\{\}\(\)])\s*', '$1'

# Shorten the result by replacing some commandlets with their aliases
$aliases = @{
	'ForEach-Object'	= if ( $standalone ) { '%%' } else { '%%%%' };
	'Get-Content'		= 'gc';
	'Invoke-Command'	= 'icm';
	'Invoke-Expression'	= 'iex';
	'Remove-Variable'	= 'rv';
	'Select-String'		= 'sls';
}

$aliases.GetEnumerator() | ForEach-Object {
	$minified = $minified -Replace $_.Name, $_.Value;
}

# =========================================================================

if ( -not $emulateFile ) {
	"powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command `"$minified`""
	exit
}

$Env:PS1_ISB = if ( $isb ) { '1' } else { '' }
$Env:PS1_FILE = $emulateFile
$Env:PS1_ARGS = ( $args | % { "`"$_`"" } ) -Join ' '

# Just to be sure in the transformation by this way only: %%%% -> %% -> %
$emulated = $minified -Replace '%%%%', '%%' -Replace '%%', '%'

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command $emulated

# =========================================================================

# EOF
