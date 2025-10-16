# Commands

There are few commands only. All of them can be performed in GUI. More description about these and other commands is available by the links below.

## List of all VMs

    vboxmanage list -s vms

## List of all running VMs

    vboxmanage list -s runningvms

## Show network settings for VM

Show a specific IP-address for the VM

    vboxmanage guestproperty get VM /VirtualBox/GuestInfo/Net/0/V4/IP

Show al IP-addresses for the VM

    vboxmanage guestproperty enumerate VM --patterns "*/V?/IP"

Show configured NICs only for the VM

    vboxmanage showvminfo VM | awk '$1 == "NIC" && $NF != "disabled"'

## Start VM in a headless mode

    vboxmanage startvm VM --type headless

## Change VM's state

    vboxmanage controlvm VM pause
    vboxmanage controlvm VM resume
    vboxmanage controlvm VM reset
    vboxmanage controlvm VM poweroff
    vboxmanage controlvm VM savestate

# Links

* https://docs.oracle.com/en/virtualization/virtualbox/6.1/user/vboxmanage.html
