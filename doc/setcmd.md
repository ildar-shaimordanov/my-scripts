_This page tells about `setcmd` script introducing more usability and flexibility to Windows batch script._

The tool was developed to enhance the functionality of `cmd.exe` 
similar to Unix-like shells. It is completely written as batch script 
and does npt add any external binaries. Nevertheless, it gives more 
functions and flexibility to `cmd.exe` and do maintainance little bit 
easier. 

In fact, this script is weak attempt to be closer to other shells - 
powerful, flexible and full-functional ones. Nevertheless, it works! 
This script can be found useful for those folks, who are not permitted 
to setup any other binaries excepting those applications permitted for 
installation. The better way is to use the other solutions like 
`Clink`, `ConEmu` or something else. 


# ENVIRONMENT VARIABLES


Behaviour of the script depends on some environment variables described 
below. Most of them have synonyms in unix and the same meaning. 

Uncomment a line if you want to turn on a feature supported by a 
variable. 


`CMD_ALIASFILE`

Define the name of the file of aliases or `DOSKEY` macros. 


`CMD_HISTFILE`

Define the name of the file in which command history is saved. 


`CMD_HISTFILESIZE`

Define the maximum number of lines in the history file. 


`CMD_HISTSIZE`

Define the maximum number of commands remembered by the buffer. 
By default `DOSKEY` stores `50` latest commands in its buffer. 


`CMD_HISTCONTROL`

A semicolon-separated list of values controlling how commands are saved 
in the history file. 

**Not implemented**


`CMD_HISTIGNORE`

A semicolon-separated list of ignore patterns used to decide which 
command lines should be saved in the history file. 

**Not implemented**


# ALIASES


`alias`

Display all aliases.


`alias name=text`

Define an alias with the name for one or more commands.


`alias -r [FILENAME]`

Read aliases from the specified file or `CMD_ALIASFILE`.


`unalias name`

Remove the alias specified by name from the list of defined aliases.
Run `DOSKEY /?` for more details.


`history`

Display or manipulate the history list for the actual session. 
Run `DOSKEY /?` for more details.


`cd`

Display or change working directory. 


`exit`

Exit the current command prompt; before exiting store the actual 
history list to the history file `CMD_HISTFILE` when it is configured. 


`CTRL-D`

`CTRL-D` (`ASCII 04`, `EOT` or the *diamond* symbol) is useful shortcut 
for the `exit` command. Unlike Unix shells the `CTRL-D` keystroke 
doesn't close window immediately. In Windows command prompt you need to 
press the `ENTER` keystroke. 


# ALIAS FILE


Alias file is the simple text file defining aliases or macros in the 
form `name=command` and can be loaded to the session by the prefedined 
alias `alias -r`.


# HISTORY


`history [options]`


## Options


`history`

Displays the history of the current session.


`history -c`

Clear the history list by setting the history size to 0 and reverting 
to the value defined in `CMD_HISTSIZE` or `50`, the default value. 


`history -C`

Install a new copy of `DOSKEY` and clear the history buffer. This way 
is less reliable and deprecated in usage because of possible loss of 
control over the command history. 


`history -w`

Write the current history to the file `CMD_HISTFILE` if it is defined. 


# CHANGE DIRECTORY


`cd [options]`


Change the current directory can be performed by the following commands 
`CD` or `CHDIR`. To change both current directory and drive the option 
'/D' is required. To avoid certain typing of the option and simplify 
navigation between the current directory, previous one and user's home 
directory, the command is extended as follows.

See the following links for details

* http://ss64.com/nt/pushd.html
* http://ss64.com/nt/popd.html
* http://ss64.com/nt/cd.html

There is another way how to combine `cd`, `pushd` and `popd`. You can 
find it following by the link:

* https://www.safaribooksonline.com/library/view/learning-the-bash/1565923472/ch04s05.html


`cd`

Display the current drive and directory.


`cd ~`

Change to the user's home directory.


`cd -`

Change to the previous directory. The previously visited directory is 
stored in the OLDCD variable. If the variable is not defined, no action 
happens. 


`cd path`

Change to the directory cpecified by the parameter.


# ADDITIONAL REFERENCES

* https://msdn.microsoft.com/ru-ru/library/windows/desktop/ee872121%28v=vs.85%29.aspx
* http://www.outsidethebox.ms/12669/
* http://www.transl-gunsmoker.ru/2010/09/11.html

