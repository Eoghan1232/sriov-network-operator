#!/bin/bash
set -x

declare -a kargs=( "$@" )
ret=0
args=$(chroot /proc/1/root/ cat /proc/cmdline)

if chroot proc/1/root/ test -f /run/ostree-booted ; then
    for t in "${kargs[@]}";do
        if [[ $args != *${t}* ]];then
            if chroot /proc/1/root/ rpm-ostree kargs | grep -vq ${t}; then
                chroot /proc/1/root/ rpm-ostree kargs --append ${t} > /dev/null 2>&1
            fi
            let ret++
        fi
    done
else
    chroot /proc/1/root/ which grubby > /dev/null 2>&1
    # if grubby is not there, let's tell it
    if [ $? -ne 0 ]; then
        exit 127
    fi
    for t in "${kargs[@]}";do
        if [[ $args != *${t}* ]];then
            if chroot /proc/1/root/ grubby --info=DEFAULT | grep args | grep -vq ${t}; then
                chroot /proc/1/root/ grubby --update-kernel=DEFAULT --args=${t} > /dev/null 2>&1
            fi
            let ret++
        fi
    done
fi

echo $ret
