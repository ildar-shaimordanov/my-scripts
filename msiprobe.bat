0</*! ::
@echo off

if "%~1" == "" (
	echo:Usage: %~n0 [msi-file [target-dir]]
	goto :EOF
)

for %%f in ( "%~1" ) do for %%d in ( "%~2" ) do if "%%~d" == "" (
	cscript //nologo //e:javascript "%~f0" "%%~ff"
) else (
	echo:Executing...
	echo:msiexec /quiet /a "%%~ff" TARGETDIR="%%~fd"
	call msiexec /quiet /a "%%~ff" TARGETDIR="%%~fd"
)

goto :EOF
*/0;

// ========================================================================

try {
	var msiFile = WScript.Arguments.item(0);
	var msiProps = getMsiProperty(msiFile);
	WScript.StdOut.WriteLine(msiProps);
} catch(e) {
	WScript.StdErr.WriteLine('Cannot probe file: ' + msiFile);
	WScript.StdErr.WriteLine('Error: ' + e.message);
	WScript.Quit(1);
}

// ========================================================================

// JS code was adapted from VBS implementation found by these links:
// https://serverfault.com/a/465717/423234
// http://scriptbox.toll.at/index.php?showcontent=Get%20MSI-File%20properties.vbs&list=1
function getMsiProperty(filename) {
	var r = getMsiView(filename, 'Select * From Property');

	var c = getColumnWidth(r, 0);

	for (var i = 0; i < r.length; i++) {
		r[i][0] = ( r[i][0] + c.padding ).slice(0, c.width);
		r[i] = r[i].join(' : ');
	}

	return r.join('\n');
}

function getMsiView(filename, sql) {
	var installer = new ActiveXObject('WindowsInstaller.Installer');
	var installerDatabase = installer.OpenDatabase(filename, 0);
	var installerView = installerDatabase.OpenView('Select * From Property');
	installerView.Execute();

	var installerRecord;

	var r = [];

	while ( installerRecord = installerView.Fetch() ) {
		var n = installerRecord.FieldCount;
		var s = [];
		for (var i = 1; i <= n; i++) {
			s.push(installerRecord.StringData(i));
		}
		r.push(s);
	}

	return r;
}

function getColumnWidth(r, j) {
	var maxLen = 0;

	for (var i = 0; i < r.length; i++) {
		maxLen = Math.max(maxLen, r[i][j].length);
	}

	return {
		width: maxLen,
		padding: new Array(maxLen + 1).join(' ')
	};
}

// ========================================================================

// EOF
