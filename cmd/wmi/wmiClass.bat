0</*! ::

:::SYNOPSIS
:::    wmiClass [/ns:Namespace] [*|class [/where:WhereClause] [*|property ...]]
:::
:::DESCRIPTION
:::  Show properties of a WMI class
:::
:::ARGUMENTS
:::    /ns:Namespace       specify the namespace (defaults to \root\cimv2)
:::    /where:WhereClause  clause to restict records
:::    class               show the properties of the given class
:::    class property      show the value of the property of the given class
:::
:::EXAMPLES
:::  List names of all WMI classes
:::    wmiClass *
:::
:::  List all properties for the given class
:::    wmiClass Win32_LocalTime
:::
:::  Show all values
:::    wmiClass Win32_LocalTime *
:::
:::  Show the specific values
:::    wmiClass Win32_LocalTime Year Month Day
:::
:::  Filter records and show the specific values
:::    wmiClass Win32_Process ProcessID Name /where:"Name = 'cmd.exe'"

::History
::  2022/02/25: Version 1.2
::  https://www.dostips.com/forum/viewtopic.php?p=66294#p66294
::  https://github.com/ildar-shaimordanov/cmd.scripts/blob/master/wmiClass.bat
::  - Rethink usage and rewrite the code significantly
::  - Add examples into the help message
::  - Add /where, the new option for limiting the number of records
::
::  Based on Version 1.1 by Antonio Perez Ayala
::  https://www.dostips.com/forum/viewtopic.php?p=66284#p66284

@echo off

if "%~1" == "" (
	findstr "^:::" "%~f0"
	goto :EOF
)

cscript //nologo //e:javascript "%~f0" %*
goto :EOF
*/0;

var args = WScript.Arguments.Unnamed;
var opts = WScript.Arguments.Named;

var className = args.length ? args.item(0) : '*';

var propNames = [];
for (var i = 1; i < args.length; i++) {
	propNames.push(args.Item(i));
}

var ns = opts.Exists('NS') ? opts.Item('NS') : '';

var wmi = GetObject('WinMgmts:' + ns);

var collection;
var fetch;

function enumerate(collection, fetch) {
	var r = [];
	for (var e = new Enumerator(collection); ! e.atEnd(); e.moveNext()) {
		r.push(fetch(e.item()));
	}
	return r;
}

if ( className == '*' ) {
	collection = wmi.SubclassesOf();
	fetch = function(el) {
		return el.Path_.Class;
	};
} else if ( propNames.length == 0 ) {
	collection = wmi.Get(className).Properties_;
	fetch = function(el) {
		return el.Name;
	};
} else {
	var whereClause = opts.Exists('WHERE') ? ' where ' + opts.Item('WHERE') : '';

	collection = wmi.ExecQuery('select * from ' + className + whereClause);
	fetch = function(el) {
		if ( propNames.length == 1 && propNames[0] == '*' ) {
			propNames = enumerate(el.Properties_, function(el) {
				return el.Name;
			});
		}

		var r = [];
		for (var i = 0; i < propNames.length; i++) {
			var n = propNames[i];
			r.push(n + "=" + el[n]);
		}
		return r.join('\n');
	}
}

WScript.StdOut.WriteLine(enumerate(collection, fetch).join('\n'));
