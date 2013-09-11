#!/bin/sh
# Do NOT add -e for this file! We want to carry on if one backend fails

logfile=benchsuite.log

rm -f $logfile

for backend in $(ls qemu/bin|grep -v cil|grep -v cpc-ucontext); do
  ./run_bench.sh $backend >> $logfile 2>&1
  sleep 30
done
