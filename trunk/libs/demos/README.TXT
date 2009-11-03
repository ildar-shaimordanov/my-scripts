DEMO USAGE
==========

There is demos folder to demonstrate the usage of the "libs" script.
Try to launch each script here with the "libs" like following example:

    ..\..\libs "LIBRARY" DEMOSCRIPT [OPTIONS]

where 

    LIBRARY     the library name without any extension.
    DEMOSCRIPT  the demo script with extension demonstrating the usage of this library.
    OPTIONS     non-mamdatory options.

    ..\..\libs "GetOptions" GetOptions.bat /two:"two words" "the more words yet" /another:word /option

The next example above shows the usage of the "GetOptions" library with several options.


COMMON USAGE
============

1. The script SCRIPT.BAT will be compiled with the libraries LIB1 and LIB2 and the 
resulting temporary file with be run with the appropriate options provided as OPTIONS.

    libs "LIB1 LIB2" SCRIPT.BAT OPTIONS

2. The same as the item 1 but after execution the temporary file will be kept on a disk.

    libs "LIB1 LIB2 /k" SCRIPT.BAT OPTIONS

3. The script SCRIPT.BAT will be compiled with the libraries LIB1 and LIB2 and will be stored 
under the same name. The original script will be backed up to the file SCRIPT.bak. 

    libs "LIB1 LIB2 /c" SCRIPT.BAT

4. The script SCRIPT.BAT will be compiled with all libraries.

    libs "/a"    SCRIPT.BAT OPTIONS
    libs "/a /k" SCRIPT.BAT OPTIONS
    libs "/a /c" SCRIPT.BAT


CONCLUSION
==========

Enjoy!

