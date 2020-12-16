0</*! ::
@echo off
cscript //nologo //e:javascript "%~f0" %*
goto :EOF */0;
/*!

// ========================================================================

The JScript code below was converted from the VBScript code that is 
published and shared via the following links

https://serverfault.com/a/465717/423234
http://scriptbox.toll.at/index.php?showcontent=Get%20MSI-File%20properties.vbs&list=1

It examines the provided MSI files for the list of public MSI properties

// ========================================================================

*/

function main() {
	if ( ! WScript.Arguments.length ) {
		alert('Usage: ' + WScript.ScriptName + ' msi-file ...');
		quit();
	}

	for (var i = 0; i < WScript.Arguments.length; i++) {
		var msiFile = WScript.Arguments.item(i);
		var msiPropertiesText = MsiFile.getPropertiesText(msiFile);
		alert(msiPropertiesText);
	}
};

var alert = alert || function() {
	WScript.Echo([].slice.call(arguments));
};

var quit = quit || function(exitCode) {
	WScript.Quit(exitCode);
};

// ========================================================================

function MsiFile() {
};

MsiFile.getProperties = function(filename) {
	var installer = new ActiveXObject('WindowsInstaller.Installer');
	var installerDatabase = installer.OpenDatabase(filename, 2);
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
};

MsiFile.getPropertiesText = function(filename) {
	var p = this.getProperties(filename);

	var r = [];
	for (var i = 0; i < p.length; i++) {
		r.push(p[i].join(' '));
	}
	return r.join('\n');
};

// ========================================================================

main();

// ========================================================================

// EOF
