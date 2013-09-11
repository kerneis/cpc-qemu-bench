#!/bin/bash -e

export TIMEFORMAT='%3R'

logfile=data/microbench.csv

rm -f $logfile

for dir in $(ls qemu/bin | grep -v gthread | grep -v cil-ucontext); do
  echo ========== $dir ===========
  make -C "qemu/bin/${dir}" tests/test-coroutine
  for i in `seq 1 10`; do
    printf "${dir}," >> $logfile
    (time qemu/bin/${dir}/tests/test-coroutine -p /perf -m perf -s 1 -q) 2>> $logfile
  done
done
