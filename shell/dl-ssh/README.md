# dl-ssh

```
NAME
  ssh downloader

SYNOPSIS
  dl-ssh [OPTIONS]

OPTIONS
  -h, --help
    Print this help and exit

  -f RCFILE, --rcfile RCFILE
    Use definitions from RCFILE (defaults to dl-ssh-rc).
    It MUST be given as the first argument in the comamnd line.

  -u RUSER, --username RUSER
    Login as RUSER

  -H RHOST, --host RHOST
    Login to RHOST

  -p RPORT, --port RPORT
    The port to connect to on the remote host (defaults to 22)

  -s RSHELL, --shell RSHELL
    Remote login shell (defaults to bash)

  -l, --login
  +l, --no-login
    Invoke shell as login shell executing shell profile scripts

  -x, --xtrace
  +x, --no-xtrace
    Print user-defined commands executed remotely and locally

  -X, --xtrace-remote
  +X, --no-xtrace-remote
    Print remotely executed commands, including those from profile scripts
```
