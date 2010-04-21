
// Display the minimal usage screen
if ( ! WScript.FullName.match(/cscript/i) || WScript.Arguments.Named.Exists('H') ) {
    WScript.Echo([
        'Usage:',
        '\tJS2BAT [/H]',
        '\tJS2BAT [file] [/W] [/A:"string"]',
    ].join('\n'));

    WScript.Quit();
}

// Define the script host to be launched (WSCRIPT or CSCRIPT)
var host = WScript.Arguments.Named.Exists('W') 
    ? 'wscript'
    : 'cscript';

// Additional arguments for the script host
var args = WScript.Arguments.Named('A') 
    ? WScript.Arguments.Named.item('A') 
    : '/nologo';

var prolog = [
    '@set @x=0 /*', 
    '@set @x=', 
    ['@', host, args, '/e:javascript "%~dpnx0" %*'].join(' '), 
    '@goto:eof */', 
    ''
].join('\n');

var e;
var lines;

if ( WScript.Arguments.Unnamed.length == 0 ) {
    try {
        lines = WScript.StdIn.ReadAll();
    } catch (e) {
        lines = '';
    }
    WScript.StdOut.Write(prolog + lines);

    WScript.Quit();
}

var fso = new ActiveXObject('Scripting.FileSystemObject');

for (var i = 0; i < WScript.Arguments.Unnamed.length; i++) {
    var j_name = WScript.Arguments.Unnamed.item(i);
    var b_name = j_name.replace(/\.js/, '.bat');

    var f, h, e;

    try {
        f = fso.GetFile(j_name);
        h = f.OpenAsTextStream();
        lines = h.ReadAll();
        h.Close();
    } catch (e) {
        // Error 62 - Input past end of file
        // It means try to read an empty file
        if ( (e.number & 0xffff) != 62 ) {
            WScript.Echo('"' + j_name + '" not found.');
            WScript.Quit(1);
        }
        lines = '';
    }

    try {
        h = fso.OpenTextFile(b_name, 2, true);
        h.Write(prolog + lines);
        h.Close();
    } catch (e) {
        WScript.Echo('Cannot write to the file "' + j_name + '".');
        WScript.Quit(1);
    }
}

WScript.Quit();
