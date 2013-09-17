#!/bin/bash -e

logfile=data/microbench.csv

rm -f $logfile

echo backend,test,iterations,time >> $logfile

# test gthread after every other because it is much slower
for dir in $(ls qemu/bin | grep -v gthread | grep -v cil-ucontext) gcc-gthread-nopool; do
  echo ========== $dir ===========
  make -C "qemu/bin/${dir}" tests/test-coroutine
  for bench in lifecycle yield nesting; do
    for i in `seq 1 10`; do
      printf "${dir},${bench}," >> $logfile
      qemu/bin/${dir}/tests/test-coroutine -m perf -p /perf/${bench} --verbose |\
        grep iterations|sed 's/.* \([^ ]*\) iterations.*: \([^ ]*\) s.*/\1,\2/' >> $logfile
    done
  done
done
