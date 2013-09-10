#!/bin/sh -e

backend=$1

if [ -z "$backend" ]
then
  echo Usage: $0 backend-name
  exit 1
fi

for rw in read write randread randwrite; do
  for job in 1 2 5 10 25 50; do
    echo TESTING: rw=$rw numjobs=$job backend=$backend
    ./run_fio.sh  ${rw} ${job} ${backend}
  done
done
