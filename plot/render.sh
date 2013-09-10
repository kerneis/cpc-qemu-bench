#!/bin/sh -e

for rw in read write; do
  for dir in "$rw" "rand${rw}"; do
      ./plot.R --args ${dir} ${rw}.bw switches
  done
done
