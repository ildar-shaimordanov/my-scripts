# `./body.sh`

Print the first line of STDIN as an output header and continue executing
the provided command.

Example:

    ps -ef | body grep $USER

# `./teem`

*teem* means *to rain heavily*. Here *teem* stands for *tee modified*,
implying that the standard `tee` tool is modified, and keeps also
connection with the meaning of the word, that's every new running
leads to teeming with new file.


    Usage: ... | teem [OPTIONS] [LABEL]
    Copy standard input to a file named 'LABEL-YYYY-mm-dd-HH-MM-SS.log'.
    If no LABEL is specified, defaults to 'tee'.
    
    Options
    	-a	Append to the file, don't overwrite
    	-i	Ignore an interrupt signal
    	-h	Print this help and exit
    

# `./try.sh`

Execute any command silently.

Example:

    try sleep 10

