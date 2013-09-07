#!/bin/bash

backend=$1

if [[ -z "$backend" ]]
then
  echo Usage: $0 backend-name
  exit 1
fi

./run_fio.sh seq-readers  read $backend
./run_fio.sh seq-writers  write $backend
./run_fio.sh rand-readers randread $backend
./run_fio.sh rand-writers randwrite $backend
