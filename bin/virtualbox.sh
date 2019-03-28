function vboxip(){
    vboxmanage guestproperty get "$1" "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}'
}

function vboxssh(){
    ssh `vboxip $1`
}
