#!/bin/bash
./run_fio.sh seq-readers  read
./run_fio.sh seq-writers  write
./run_fio.sh rand-readers randread
./run_fio.sh rand-writers randwrite
