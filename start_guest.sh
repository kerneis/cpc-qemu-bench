#!/bin/sh -e

backend=$1

if [ -z "$backend" ]
then
  echo Usage: $0 backend
  echo Available backends:
  ls qemu/bin
  exit 1
fi

QEMU_BIN=qemu/bin/${backend}/x86_64-softmmu/qemu-system-x86_64
IMAGE=testbedhdd.img


ulimit -c 1000000

exec $QEMU_BIN -hda $IMAGE -redir tcp:2222::22 -display none \
  -kernel vmlinuz-2.6.32-5-amd64 -initrd initrd.img-2.6.32-5-amd64 -append "root=UUID=59b71651-73fa-4887-95a5-34b6654738c3 ro"
