<!-- toc-begin -->
# Table of Content
* [NAME](#name)
* [SYNOPSIS](#synopsis)
* [DESCRIPTION](#description)
  * [Show the name, uuid and current state per each VM](#show-the-name-uuid-and-current-state-per-each-vm)
  * [Start and stop/shudown/poweroff VM](#start-and-stopshudownpoweroff-vm)
  * [Restart/reboot/reset VM](#restartrebootreset-vm)
  * [Pause and resume VM](#pause-and-resume-vm)
  * [Save and discard state VM](#save-and-discard-state-vm)
  * [Connect to VM via SSH](#connect-to-vm-via-ssh)
  * [Show VM network interfaces](#show-vm-network-interfaces)
* [REQUIREMENTS](#requirements)
* [SEE ALSO](#see-also)
<!-- toc-end -->


# NAME

`vboxctl` - manage VirtualBox VMs

# SYNOPSIS

    vboxctl command [OPTIONS]

# DESCRIPTION

This script is supposed to simplify and unify invocation of a few
useful commands.


## Show the name, uuid and current state per each VM

    vboxmanage list --long vms \
    | grep -E '^(Name|UUID|State)'


## Start and stop/shudown/poweroff VM

    vboxmanage startvm $VM --type headless
    vboxmanage controlvm $VM poweroff

## Restart/reboot/reset VM

    vboxmanage controlvm $VM reset

## Pause and resume VM

    vboxmanage controlvm $VM pause
    vboxmanage controlvm $VM resume

## Save and discard state VM

    vboxmanage controlvm $VM savestate
    vboxmanage discardstate $VM


## Connect to VM via SSH

It is assumed the command should be executed similar to `kubectl
exec`. However, it's still experimental and there is no guarantee it
is going to be left in the future.


## Show VM network interfaces

It looks like invoking the following two commands and combining their
output into the `ifconfig`-like result.

    vboxmanage guestproperty enumerate $VM --patterns '*/Net/*' \
    | awk -F '[:,] +' '{ print $2, $4 }' \
    | sort

    vboxmanage showvminfo $VM \
    | awk '$1 == "NIC" && $NF != "disabled"'


# REQUIREMENTS

* vboxmanage
* bash
* perl
* awk

# SEE ALSO

* https://github.com/stockrt/vboxctl
* https://github.com/janth/vbox-snippets
