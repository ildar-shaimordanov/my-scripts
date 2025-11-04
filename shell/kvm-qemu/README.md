# `./virt-exec`

# USAGE


    Check if qemu agent is configured and command execution is enabled.
    Execute a command using qemu agent of the virtual machine.
    Enable piping data to STDIN of the virtual machine.
    Pass environment variables defined on the host or created in the command line.
    Capture STDOUT and STDERR and output them on the host respectively.
    Return ExitCode of the command.
    Usage:
    	virt-exec [-c|-C|-e ENV[=VALUE] ...] DOMAIN COMMAND [COMMAND_OPTIONS]
    


# Requirements

* virsh
* jq - for handling JSON
* base64
* POSIX shell (like Almquist shell) or bash

base64 is required to encode STDIN while preparing "input-data". Also
it's used to decode "out-data" and "err-data", both captured from
the virtual machine (due to some Linux are shipped with jq 1.5-1 not
supporting `@base64d`).

# See Also

* https://www.qemu.org/docs/master/interop/qemu-ga-ref.html
* https://manpages.ubuntu.com/manpages/bionic/man7/qemu-ga-ref.7.html
* https://www.libvirt.org/manpages/virsh.html
* https://github.com/3hedgehogs/qemu-agent-commands

# `./virt-list`

List VMs or networks


    List VMs or networks
    
    Usage: virt-list [-a] [-d|-n]
    
    Options
    	-d	List virtual machines ordered by networks
    	-n	List virtual networks (similar to `ip addr show`)
    	-a	List all active and inactive VMs and networks
    


Requirements

* virsh
* awk
* sed

Technical details for `virt-list -d [-a]`:

`virsh dumpxml --xpath` outputs results as follows:

    VM_NAME
     network="VM_NETWORK"

`awk` reorders and groups data accordingly network names:

    VM_NETWORK
      VM_NAME

Technical details for `virt-list -n [-a]`:

Because of some limitation of XPath used in `virsh ... --xpath` (at
least in the version I use), `sed` is used to perform some replacement.

