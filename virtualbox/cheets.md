# Commands

There are few commands only. Most of them can be performed in GUI.

## List of all VMs

    vboxmanage list -s vms

## List of all running VMs

    vboxmanage list -s runningvms

## Show network settings for VM

Show a specific IP-address for the VM

    vboxmanage guestproperty get {uuid|name} /VirtualBox/GuestInfo/Net/0/V4/IP

Show al IP-addresses for the VM

    vboxmanage guestproperty enumerate {uuid|name} --patterns "*/V?/IP"

Show configured NICs only for the VM

    vboxmanage showvminfo {uuid|name} | awk '$1 == "NIC" && $NF != "disabled"'

## Start VM in a headless mode

    vboxmanage startvm {uuid|name} --type headless

## Change VM's state

    vboxmanage controlvm {uuid|name} pause
    vboxmanage controlvm {uuid|name} resume
    vboxmanage controlvm {uuid|name} reset
    vboxmanage controlvm {uuid|name} poweroff
    vboxmanage controlvm {uuid|name} savestate

# Links

* https://docs.oracle.com/en/virtualization/virtualbox/6.1/user/vboxmanage.html
