0</*! ::

::Probe and unpack a MSI file.
::
::Usage:
::    msiprobe msi-file /LIST
::    msiprobe msi-file /PROPERTY
::    msiprobe msi-file target-dir

@echo off

for %%f in ( "%~1" ) do for %%d in ( "%~2" ) do if /i "%%~d" == "" (
	for /f "usebackq tokens=* delims=:" %%s in ( "%~f0" ) do (
		if /i "%%s" == "@echo off" goto :EOF
		if not "%%s" == "0</*! ::" echo:%%s
	)
) else if /i "%%~d" == "/LIST" (
	cscript //nologo //e:javascript "%~f0" "%%~ff" /LIST
) else if /i "%%~d" == "/PROPERTY" (
	cscript //nologo //e:javascript "%~f0" "%%~ff" /PROPERTY
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
	var mode = WScript.Arguments.item(1);
	var msiInfo =
		mode.match(/^\/LIST$/i) ? getMsiListing(msiFile) :
		mode.match(/^\/PROPERTY$/i) ? getMsiProperty(msiFile) :
		'/LIST or /PROPERTY required';
	WScript.StdOut.WriteLine(msiInfo);
} catch(e) {
	WScript.StdErr.WriteLine('Cannot probe file: ' + msiFile);
	WScript.StdErr.WriteLine('Error: ' + e.message);
	WScript.Quit(1);
}

// ========================================================================

// JS code was adapted from VBS implementation found by these links:
// https://serverfault.com/a/465717/423234
// http://scriptbox.toll.at/index.php?showcontent=Get%20MSI-File%20properties.vbs&list=1
// https://www.hanselman.com/blog/how-to-list-all-the-files-in-an-msi-installer-using-vbsciript

function getMsiListing(filename) {
	return getMsiView(filename, {
		header: 'FileSize FileName'.split(' '),
		sql: 'Select FileSize, FileName From File',
		align: function(value, width, padding) {
			return ( padding + value ).slice(-width);
		}
	});
}

function getMsiProperty(filename) {
	return getMsiView(filename, {
		header: 'Property Value'.split(' '),
		sql: 'Select * From Property',
		align: function(value, width, padding) {
			return ( value + padding ).slice(0, width);
		}
	});
}

function getMsiView(filename, options) {
	var installer = new ActiveXObject('WindowsInstaller.Installer');
	var installerDatabase = installer.OpenDatabase(filename, 0);
	var installerView = installerDatabase.OpenView(options.sql);
	installerView.Execute();

	var installerRecord;

	var r = [];
	var maxLen = 0;

	while ( installerRecord = installerView.Fetch() ) {
		var n = installerRecord.FieldCount;
		var s = [];
		for (var i = 1; i <= n; i++) {
			s.push(installerRecord.StringData(i));
		}
		maxLen = Math.max(maxLen, s[0].length);
		r.push(s);
	}

	var padding = new Array(maxLen + 1).join(' ');

	r.unshift(options.header);

	for (var i = 0; i < r.length; i++) {
		r[i][0] = options.align(r[i][0], maxLen, padding);
		r[i] = r[i].join(' : ');
	}

	return r.join('\n');
}

// ========================================================================

// EOF
