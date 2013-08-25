#!/bin/bash

QEMU_BIN=qemu
IMAGE=testbedhdd.img

$QEMU_BIN -hda $IMAGE -redir tcp:2222::22 -monitor stdio -name CPC-Test -nographic
