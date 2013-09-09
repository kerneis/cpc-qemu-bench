#!/bin/bash -e

backend=$1

if [[ -z "$backend" ]]
then
  echo Usage: $0 backend-name
  exit 1
fi

# TODO: add randread randwrite
for rw in read write; do
  for job in 1 2 3 4 5 6 7 8 9 10; do
    echo TESTING: rw=$rw numjobs=$job backend=$backend
    ./run_fio.sh  ${rw} ${job} ${backend}
  done
done
