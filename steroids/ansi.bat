<# :
@echo off
setlocal
set "POWERSHELL_BAT_ARGS=%*"
if defined POWERSHELL_BAT_ARGS set "POWERSHELL_BAT_ARGS=%POWERSHELL_BAT_ARGS:"=\"%"
endlocal & powershell -NoLogo -NoProfile -Command "$_ = $input; Invoke-Expression $( '$input = $_; $_ = \"\"; $args = @( &{ $args } %POWERSHELL_BAT_ARGS% );' + [String]::Join( [char]10, $( Get-Content \"%~f0\" ) ) )"
goto :EOF
#>

# =========================================================================

$ProgName = if ( $MyInvocation.MyCommand.Name ) { $MyInvocation.MyCommand.Name } else { "ANSI" };

$Version = "0.1 Alpha";

$Help = @"
$ProgName [ --dos-colors ] [ --restore ] [text ...]

--dos-colors  Use DOS colors instead ANSI (See "COLOR /?")
--restore     Restore the colors to the values set before the starting

--help        Print this help
--man         Print the manual
--version     Print the version

Parse the specified text from the command line or pipe and output it 
accordingly the ANSI codes provided within the text.
"@;

$Manual = @"
$Help

ESCAPING

Interpret the following escaped characters:
  \a        Bell
  \b        Backspace
  \c        Suppress further output
  \e        Escape character
  \f        Form feed
  \n        New line
  \r        Carriage return
  \t        Horizontal tabulation
  \v        Vertical tabulation
  \\        Backslash
  \0nnn     The character by its ASCII code (octal)
  \xHH      The character by its ASCII code (hexadecimal)

ANSI SEQUENCES

  <ESC> [ <list> <code>

  <ESC>     Escape character in the form "\e", "\033", "\x1B", "^["
  <list>    The list of numeric codes
  <code>    The sequence code

Moves the cursor n (default 1) cells in the given direction. If the cursor 
is already at the edge of the screen, this has no effect.
  \e[nA     Cursor Up
  \e[nB     Cursor Down
  \e[nC     Cursor Forward
  \e[nD     Cursor Back

Moves cursor to beginning of the line n (default 1).
  \e[nE     Cursor Next Line
  \e[nF     Cursor Previous Line

Cursor position
  \e[nG     Moves the cursor to column n.
  \e[n;mH   Moves the cursor to row n, column m.
  \e[n;mf   The same as above.

Erasing
  \e[nJ     Clears part of the screen. If n is 0 (or missing), clear from 
            cursor to end of screen. If n is 1, clear from cursor to 
            beginning of the screen. If n is 2, clear entire screen.
  \e[nK     Erases part of the line. If n is zero (or missing), clear from 
            cursor to the end of the line. If n is one, clear from cursor 
            to beginning of the line. If n is two, clear entire line. 
            Cursor position does not change.

Colorizing
  \e[n1[;n2;...]m, where n's are as follows:

  0         All attributes off
  1         Increase intensity
  2         Faint (decreased intensity)
  7         Reverse (invert the foreground and background colors)
  30-37     Set foreground color (30+x, where x from the tables below)
  39        Default foreground text color
  40-47     Set background color (40+x)
  49        Default background color
  90-97     Set foreground color, high intensity (90+x)
  100-107   Set background color, high intensity (100+x)

DIFFERENCES BETWEEN ANSI AND DOS COLORS

ANSI colors (default usage)
  Intensity 0       1       2       3       4       5       6       7
  Normal    Black   Red     Green   Yellow  Blue    Magenta Cyan    White
  Bright    Black   Red     Green   Yellow  Blue    Magenta Cyan    White

DOS colors (available by the "--dos-colors" option)
  Intensity 0       1       2       3       4       5       6       7
  Normal    Black   Blue    Green   Aqua    Red     Purple  Yellow  White
  Bright    Gray    Blue    Green   Aqua    Red     Purple  Yellow  White

REFERENCES

http://en.wikipedia.org/wiki/ANSI_escape_code
http://misc.flogisoft.com/bash/tip_colors_and_formatting
http://ss64.com/nt/color.html
http://stackoverflow.com/a/24273024/3627676
"@;

# =========================================================================

if ( $args[0] -eq "--help" ) {
	Write-Host $Help;
	exit;
}

if ( $args[0] -eq "--man" ) {
	Write-Host $Manual;
	exit;
}

if ( $args[0] -eq "--version" ) {
	Write-Host "$ProgName $Version";
	exit;
}

# =========================================================================

$AnsiColor = @( 
	0,  4,  2,  6,  1,  5,  3,  7, 
	8, 12, 10, 14,  9, 13, 11, 15
);

$DosColor = @(
	0,  1,  2,  3,  4,  5,  6,  7, 
	8,  9, 10, 11, 12, 13, 14, 15
);

$ColorIndex = $AnsiColor;

if ( $args[0] -eq "--dos-colors" ) {
	$ColorIndex = $DosColor;
	$null, $args = $args;
	$args = @( $args );
}

$RestoreColors = $False;

if ( $args[0] -eq "--restore" ) {
	$RestoreColors = $True;
	$null, $args = $args;
	$args = @( $args );
}

# =========================================================================

$HostColor = @{};

function save-host-colors {
	$Script:HostColor = @{
		"foreground" = $Host.UI.RawUI.ForegroundColor;
		"background" = $Host.UI.RawUI.BackgroundColor;
	};
}

function restore-host-colors {
	if ( ! $RestoreColors ) {
		return;
	}
	$Host.UI.RawUI.ForegroundColor = $HostColor.foreground;
	$Host.UI.RawUI.BackgroundColor = $HostColor.background;
}

# =========================================================================

function set-ansi-color( [array]$colors ) {
	for ($i = 0; $i -lt $colors.count; $i++) {
		switch -wildcard ( $colors[$i] ) {
		0 {
			# Reset / Normal
			# restore-host-colors;
			$Host.UI.RawUI.ForegroundColor = 7;
			$Host.UI.RawUI.BackgroundColor = 0;
			break;
			}
		1 {
			# Bold or increased intensity
			$Host.UI.RawUI.ForegroundColor = $Host.UI.RawUI.ForegroundColor -bor 0x08;
			break;
			}
		2 {
			# Faint (decreased intensity)
			$Host.UI.RawUI.ForegroundColor = $Host.UI.RawUI.ForegroundColor -band 0xf8;
			break;
			}
		7 {
			# Reverse (invert the foreground and background colors)
			$Host.UI.RawUI.ForegroundColor, $Host.UI.RawUI.BackgroundColor = $Host.UI.RawUI.BackgroundColor, $Host.UI.RawUI.ForegroundColor;
			break;
			}
		{ $_ -ge 30 -and $_ -le 37 } {
			# Set text color (foreground)
			$_ = $ColorIndex[ $_ - 30 ];
			$Host.UI.RawUI.ForegroundColor = $Host.UI.RawUI.ForegroundColor -band 0xf8 -bor $_;
			break;
			}
		39 {
			# Default text color (foreground)
			# $Host.UI.RawUI.ForegroundColor = $Host.UI.RawUI.ForegroundColor -band 0xf8 -bor $HostColor.foreground;
			$Host.UI.RawUI.ForegroundColor = 7;
			break;
			}
		{ $_ -ge 40 -and $_ -le 47 } {
			# Set background color
			$_ = $ColorIndex[ $_ - 40 ];
			$Host.UI.RawUI.BackgroundColor = $Host.UI.RawUI.BackgroundColor -band 0xf8 -bor $_;
			break;
			}
		49 {
			# Default background color
			# $Host.UI.RawUI.BackgroundColor = $Host.UI.RawUI.BackgroundColor -band 0xf8 -bor $HostColor.background;
			$Host.UI.RawUI.BackgroundColor = 0;
			break;
			}
		{ $_ -ge 90 -and $_ -le 97 } {
			# Set foreground text color, high intensity
			$_ = $ColorIndex[ $_ - 90 ] + 8;
			$Host.UI.RawUI.ForegroundColor = $_;
			break;
			}
		{ $_ -ge 100 -and $_ -le 107 } {
			# Set background color, high intensity
			$_ = $ColorIndex[ $_ - 100 ] + 8;
			$Host.UI.RawUI.BackgroundColor = $_;
			break;
			}
		}
	}
}

# =========================================================================

function set-cursor-position( [array]$position, [string]$movement ) {
	if ($position.count -ne 2 ) {
		$position += 1;
	}
	for ($i = 0; $i -lt $position.count; $i++) {
		if ( $position[$i] -eq 0 ) {
			$position[$i] = 1;
		}
	}

	$row = $Host.UI.RawUI.CursorPosition.Y - $Host.UI.RawUI.WindowPosition.Y;
	$col = $Host.UI.RawUI.CursorPosition.X - $Host.UI.RawUI.WindowPosition.X;

	switch ( $movement ) {
	"A" {
		# Cursor Up
		$row = $row - $position[0];
		break;
		}
	"B" {
		# Cursor Down
		$row = $row + $position[0];
		break;
		}
	"C" {
		# Cursor Forward
		$col = $col + $position[0];
		break;
		}
	"D" {
		# Cursor Back
		$col = $col - $position[0];
		break;
		}
	"E" {
		# Cursor Next Line. Moves cursor to beginning of the line 
		# n (default 1) lines down.
		$row = $row + $position[0];
		$col = $Host.UI.RawUI.WindowPosition.X;
		break;
		}
	"F" {
		# Cursor Previous Line. Moves cursor to beginning of the 
		# line n (default 1) lines up.
		$row = $row - $position[0];
		$col = $Host.UI.RawUI.WindowPosition.X;
		break;
		}
	"G" {
		# Moves the cursor to column n.
		$col = $position[0] - 1;
		break;
		}
	{ $_ -eq "H" -or $_ -eq "f" } {
		# Cursor Position. Moves the cursor to row n, column m.
		$row = $position[0] - 1;
		$col = $position[1] - 1;
		break;
		}
	}

	if ( $row -lt $Host.UI.RawUI.WindowSize.Height ) {
		$row = [Math]::min( [Math]::max($row, 0), $Host.UI.RawUI.WindowSize.Height - 1 ) + $Host.UI.RawUI.WindowPosition.Y;
	} else {
		$row = [Math]::min( [Math]::max($row + $Host.UI.RawUI.WindowPosition.Y, 0), $Host.UI.RawUI.BufferSize.Height - 1 );
	}

	if ( $col -lt $Host.UI.RawUI.WindowSize.Width ) {
		$col = [Math]::min( [Math]::max($col, 0), $Host.UI.RawUI.WindowSize.Width - 1 ) + $Host.UI.RawUI.WindowPosition.X;
	} else {
		$col = [Math]::min( [Math]::max($col + $Host.UI.RawUI.WindowPosition.X, 0), $Host.UI.RawUI.BufferSize.Width - 1 );
	}

	[System.Console]::CursorTop = $row;
	[System.Console]::CursorLeft = $col;
}

# =========================================================================

function erase-display( [array]$mode ) {
	if ( $mode[0] -eq 2 ) {
		# clear entire screen.
		Clear-Host;
		return;
	}

	# Store the original cursor position
	$posX = $Host.UI.RawUI.CursorPosition.X;
	$posY = $Host.UI.RawUI.CursorPosition.Y;

	# Cursor position within the window
	$x = $posX - $Host.UI.RawUI.WindowPosition.X;
	$y = $posY - $Host.UI.RawUI.WindowPosition.Y;

	$w = $Host.UI.RawUI.WindowSize.Width;
	$h = $Host.UI.RawUI.WindowSize.Height;

	switch ( $mode[0] ) {
	0 {
		# clear from cursor to end of screen.
		$s = " " * ( $h * $w - ( $y * $w + $x ) );
		Write-Host -NoNewLine $s;

		break;
		}
	1 {
		# clear from cursor to beginning of the screen.
		[System.Console]::CursorTop = $Host.UI.RawUI.WindowPosition.Y;
		[System.Console]::CursorLeft = $Host.UI.RawUI.WindowPosition.X;

		$s = " " * ( $y * $w + $x );
		Write-Host -NoNewLine $s;

		break;
		}
	default {
		return;
		}
	}

	# Restore to the original cursor position
	[System.Console]::CursorTop = $posY;
	[System.Console]::CursorLeft = $posX;
}

# =========================================================================

function erase-line( [array]$mode ) {
	# Store the original cursor position
	$posX = $Host.UI.RawUI.CursorPosition.X;
	$posY = $Host.UI.RawUI.CursorPosition.Y;

	# Cursor position within the window
	$x = $posX - $Host.UI.RawUI.WindowPosition.X;
	$y = $posY - $Host.UI.RawUI.WindowPosition.Y;

	$w = $Host.UI.RawUI.WindowSize.Width;
	$h = $Host.UI.RawUI.WindowSize.Height;

	switch ( $mode[0] ) {
	0 {
		# clear from cursor to end of screen.
		$s = " " * ( $w - $x );
		break;
		}
	1 {
		# clear from cursor to beginning of the screen.
		$s = " " * $x;
		break;
		}
	2 {
		# clear entire screen.
		$s = " " * $w;
		break;
		}
	default {
		return;
		}
	}

	if ( $mode[0] -ne 0 ) {
		[System.Console]::CursorLeft = $Host.UI.RawUI.WindowPosition.X;
	}

	Write-Host -NoNewLine $s;

	# Restore to the original cursor position
	[System.Console]::CursorTop = $posY;
	[System.Console]::CursorLeft = $posX;
}

# =========================================================================

function process-ansi-sequence ( [string]$sequence, [string]$code ) {
	$seq = $sequence.split(";");
	for ($i = 0; $i -lt $seq.count; $i++) {
		$seq[$i] = [int]$seq[$i];
	}

	switch -wildcard ( $code ) {
	"m" {
		set-ansi-color $seq;
		break;
		}
	"[A-Hf]" {
		set-cursor-position $seq $code;
		break;
		}
	"J"	{
		erase-display $seq;
		break;
		}
	"K"	{
		erase-line $seq;
		break;
		}
	}
}

# =========================================================================

$MetaChars = @{
	"\\a" = [char]7;
	"\\b" = [char]8;
	"\\e" = [char]27;
	"\\f" = [char]12;
	"\\n" = [char]10;
	"\\r" = [char]13;
	"\\t" = [char]9;
	"\\v" = [char]11;
	"\\\\" = "\\";
};

function parse-metachar-string( [string]$string ) {
	# 1. Don't display anything following "\c"
	$string = $string -replace "\\c.*", "";

	# 2. Convert metacharacters to the proper characters
	foreach ( $p in $MetaChars.GetEnumerator() ) {
		$string = $string -replace $p.Name, $p.Value;
	}

	# NB: Code optimization is expected for 3.a and 3.b

	# 3.a. Convert the octal presentation to characters
	$re = [regex]"\\0[0-7]{1,3}";
	$found = @( $re.Matches($string) | select -uniq );
	for ( $i = 0; $i -lt $found.count; $i++ ) {
		$code = ( [string]$found[$i] ).Substring(2);
		$char = [char][Convert]::toInt16( $code, 8 );
		$string = $string.Replace( $found[$i], $char );
	}

	# 3.b. Convert the hexadecimal presentation to characters
	$re = [regex]"\\x[0-9A-Fa-f]{1,2}";
	$found = @( $re.Matches($string) | select -uniq );
	for ( $i = 0; $i -lt $found.count; $i++ ) {
		$code = ( [string]$found[$i] ).Substring(2);
		$char = [char][Convert]::toInt16( $code, 16 );
		$string = $string.Replace( $found[$i], $char );
	}

	return $string;
}

# =========================================================================

function parse-ansi-string( [string]$string ) {
	$string = parse-metachar-string($string);

	$re = [regex]"(?:\x1b|\^\[|\\e)\[((?:\d+;)*\d+)?([A-JKSTfhilmnsu])";
	$found = $re.Matches($string);

	$pos = 0;

	for ( $i = 0; $i -lt $found.count; $i++ ) {
		Write-Host -NoNewLine $string.Substring( $pos, $found[$i].Index - $pos );
		$pos = $found[$i].Index + $found[$i].Length;
		process-ansi-sequence $found[$i].Groups[1].Value $found[$i].Groups[2].Value;
	}

	Write-Host $string.Substring($pos);
}

# =========================================================================

save-host-colors;

if ( $args.length -gt 0 ) {
	parse-ansi-string $args;
} else {
	$input | % { parse-ansi-string $_ };
}

restore-host-colors;

# =========================================================================

# EOF
