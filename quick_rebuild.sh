#!/bin/sh -e

for dir in $(ls qemu/bin); do
  echo ========== $dir ===========
  # fix config-host.mak if necessary
  sed -i 's/^extra_cflags=\([^"].*\)$/extra_cflags="\1"/' "qemu/bin/${dir}/config-host.mak"
  # rebuild
  make -C "qemu/bin/${dir}"
done
