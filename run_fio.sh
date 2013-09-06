#!/bin/bash

name=$1
rw=$2

cmd="fio --minimal --name=$name --rw=$rw --bs=8k --size=900m --direct=1 --numjobs=1"
log=data/${name}-$(date +%Y%m%d%H%M%S).log

rm -f $log

uname -a >> $log
file testbedhdd.img >> $log
echo $cmd >> $log
echo "Host:" >> $log
$cmd >> $log
echo "Guest:" >> $log
./run_guest.sh $cmd >> $log
