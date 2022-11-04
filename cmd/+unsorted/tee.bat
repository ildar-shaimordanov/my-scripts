0</*! ::
::>Usage: tee [/a] [FILE]...
::>
::>Copy STDIN to each file and also to STDOUT
::>
::>/a  Append to the given files, don't overwrite
@echo off
timeout /t 0 >nul 2>&1 && (
	for /f "tokens=1,* delims=>" %%a in ( 'findstr "^::>" "%~f0"' ) do echo:%%b
	goto :EOF
)

cscript //nologo //e:javascript "%~f0" %*
goto :EOF
*/0;

// Declare synonyms and references to the global WSH objects
var stdin  = WScript.StdIn;
var stdout = WScript.StdOut;
var stderr = WScript.StdErr;

var nargs = WScript.Arguments.Named;
var uargs = WScript.Arguments.Unnamed;

var fso = new ActiveXObject('Scripting.FileSystemObject');

// Constants
var F_MODE_WRITE = 2;
var F_MODE_APPEND = 8;
var F_FORMAT_DEFAULT = -2;

// Append or overwrite
var append = nargs.Exists('A');

// STDOUT is one of the targets
var files = [ {
	filename: '<stdout>',
	handler: stdout
} ];

for (var i = 0; i < uargs.length; i++) {
	var e;
	try {
		var f = uargs.item(i);
		var h = fso.OpenTextFile(
			f,
			append ? F_MODE_APPEND : F_MODE_WRITE,
			true,
			F_FORMAT_DEFAULT);
		files.push({
			filename: f,
			handler: h
		});
	} catch(e) {
		// Don't stop execution, just report the problem and continue
		stderr.WriteLine([
			WScript.ScriptName,
			f,
			e.description
		].join(': '));
	}
}

// Read STDIN line by line and put each line to all available targets
while ( ! stdin.AtEndOfStream ) {
	var line = stdin.ReadLine();
	for (var i = 0; i < files.length; i++) {
		files[i].handler.WriteLine(line);
	}
}

// Let's close all files gracefully
for (var i = 1; i < files.length; i++) {
	files[i].handler.Close();
}
