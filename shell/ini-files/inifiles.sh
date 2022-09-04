#!/bin/bash

# This is a simple INI file parser to be used with bash scripts.
#
#
# SYNOPSIS
#
# $ cat example.ini
# [server]
# port = 80
# hostname = localhost
# ipaddress = 127.0.0.1
# [user]
# name = John Doe
# email = john.doe@example.com
#
# $ cat example.sh
# #!/bin/bash
#
# source inifiles.sh
#
# ini_eval user 'example.ini'
#
# echo "User Name  : $user_name"
# echo "User Email : $user_email"
#
#
# FUNCTIONS
#
# ini_read [-eval] section [inifile]
# Reads the specified section from INI file. If option the "-eval" is 
# specified, the found content will be eval'd and populate shell variables 
# named as "section_XXX". Otherwise, the content of the section will be 
# displayed.
#
# ini_eval section [inifile]
# Reads the specified section from INI file and eval them to shell 
# variables named as "section_XXX".
#
#
# ENVIRONMENT
#
# $INIFILE
# Defines the name of the INI file by default. If the name of INI file is 
# not defined, this value will be used as INI file.
#
# $INIFILE_SECSTART
# Template defined for the beginning of the section. The special substring 
# SECTION_NAME is mandatory and will be replaced when parsing the INI 
# file. Default value is "[SECTION_NAME]".
#
# $INIFILE_SECSTOP
# Template defined for the end of the section. The special substring 
# SECTION_NAME is optional and will be replaced when parsing the INI file. 
# Default value is "[".
#
#
# LINKS
#
# There are another solutions regarding INI file parsing
#
# https://github.com/rudimeier/bash_ini_parser
# https://github.com/wallyhall/shini

function ini_eval()
{
	ini_read -eval "$1" "${2:-$INIFILE}"
}

function ini_read()
{
	if [ "$1" == "-eval" ]
	then
		shift
		eval "$( $FUNCNAME "$@" )"
		return
	fi

	local sec="${1:?Section required}"
	local cfg="${2:?Config file required}"

	local INIFILE_SECSTART="${INIFILE_SECSTART:-[SECTION_NAME]}"
	local INIFILE_SECSTOP="${INIFILE_SECSTOP:-[}"

	perl -nle '
		BEGIN {
			$sec = q('"$sec"');

			( $sec_start = q('"$INIFILE_SECSTART"') ) =~ s/SECTION_NAME/$sec/;
			( $sec_stop  = q('"$INIFILE_SECSTOP"') ) =~ s/SECTION_NAME/$sec/;
		}

		# Only for all lines between two [sections]
		next LINE unless /^\s*\Q$sec_start\E/ ... /^\s*\Q$sec_stop\E/;

		# Remove trailing and leading whitespaces
		s/\s+$//;
		s/^\s+//;

		# Remove comments, empty lines and sections
		next LINE if /^#/ || /^$/ || /^\Q$sec_start\E/ || /^\Q$sec_stop\E/;

		# Shell style assignment statements
		$_ = ( $n++ ) . "=$_" unless /^\w+\s*=/;

		# Remove whitespaces around equal (=)
		s/\s*=\s*/=/;

		# Safe shell assignment operators using ANSI C like strings
		# http://wiki.bash-hackers.org/syntax/quoting
		s/=(.*)/=\$'\''$1'\''/;

		# Section name as prefix
		s/^/${sec}_/;

		# Print out config entry
		print;
	' -- "$cfg"
}
