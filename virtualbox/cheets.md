# Commands

There are few commands only.

## List of all VMs

    vboxmanage list -s vms

## List of all running VMs

    vboxmanage list -s runningvms

## Show a specific IP-address for a specific VM

    vboxmanage guestproperty get {uuid|name} /VirtualBox/GuestInfo/Net/0/V4/IP

## Show all IP-addresses for a secific VM

    vboxmanage guestproperty enumerate {uuid|name} --patterns "*/V?/IP"

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
