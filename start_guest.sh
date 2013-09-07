#!/bin/bash

QEMU_BIN=qemu/bin/$1/x86_64-softmmu/qemu-system-x86_64
IMAGE=testbedhdd.img


ulimit -c 1000000

$QEMU_BIN -hda $IMAGE -redir tcp:2222::22 -monitor stdio -name CPC-Test -nographic \
  -kernel /boot/vmlinuz-2.6.32-5-amd64 -initrd /boot/initrd.img-2.6.32-5-amd64 -append "root=UUID=59b71651-73fa-4887-95a5-34b6654738c3 ro"
# QEMU seems to suppress echo, at least in tmux
reset
