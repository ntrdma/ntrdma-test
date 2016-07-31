#!/bin/bash

HOST=$1
VERS=$2

function cmd() { echo "$@" ; "$@" ; }

cmd rsync -rplcv "install/" "$HOST:/"
cmd ssh "$HOST" dracut "/boot/initramfs-$VERS.img" "$VERS"
cmd ssh "$HOST" grub2-mkconfig -o "/etc/grub2.cfg"
cmd ssh "$HOST" grub2-set-default 0
cmd ssh "$HOST" reboot

true
