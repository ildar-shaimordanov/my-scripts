<# :
@echo off
setlocal
rem Any non-empty value changes the script invocation: the script is
rem executed using ScriptBlock instead of Invoke-Expression as default.
set "PS1_ISB="
set "PS1_FILE=%~f0"
set "PS1_ARGS=%*"
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$a=($Env:PS1_ARGS|sls -Pattern '\"(.*?)\"(?=\s|$)|(\S+)' -AllMatches).Matches;$a=@(@(if($a.count){$a})|%%{$_.value -Replace '^\"','' -Replace '\"$',''});$f=gc $Env:PS1_FILE -Raw;if($Env:PS1_ISB){$input|&{[ScriptBlock]::Create('rv f,a -Scope Script;'+$f).Invoke($a)}}else{$i=$input;iex $('$input=$i;$args=$a;rv i,f,a;'+$f)}"
goto :EOF
#>
# =========================================================================

$Win32 = Add-Type -MemberDefinition @"
[DllImport("msvcrt.dll", EntryPoint = "_get_osfhandle", SetLastError = true)]
public static extern IntPtr GetOsfHandle(int fd);

[DllImport("kernel32.dll", SetLastError = true)]
public static extern uint GetFileType(IntPtr hFile);

[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
"@ -Name "Win32FdTTY" -Namespace "Kernel32" -PassThru

function Test-IsAtty {
	param (
		[Parameter(Mandatory=$true)]
		[int]$Fd
	)

	# Convert a CRT FD (POSIX-style) to a native Windows system HANDLE
	$hStream = $Win32::GetOsfHandle($Fd)

	# Validate the system HANDLE against null or INVALID_HANDLE_VALUE (-1)
	if ($hStream -eq [IntPtr]::Zero -or $hStream -eq -1) {
		return $false
	}

	# Check the device type is character (FILE_TYPE_CHAR = 0x0002)
	$FILE_TYPE_CHAR = 0x0002
	$fileType = $Win32::GetFileType($hStream)
	if ($fileType -ne $FILE_TYPE_CHAR) {
		return $false
	}

	# Verify if the character device is an actual interactive console (TTY)
	[uint32]$mode = 0
	return $Win32::GetConsoleMode($hStream, [ref]$mode)
}

# =========================================================================

$isTty = Test-IsAtty -Fd $args[0]
exit [int](-not $isTty)

# =========================================================================

# EOF
