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

exec $QEMU_BIN -machine accel=kvm -drive cache=none,file="$IMAGE" -redir tcp:2222::22 -display curses
