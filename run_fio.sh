#!/bin/bash

name=$1
rw=$2
backend=$3

cmd="fio --minimal --name=$name --rw=$rw --bs=32k --runtime=30 --time_based --size=100m --numjobs=10"
logdir=$(date +data/%Y/%m/%d)
log=${logdir}/${name}-${backend}-$(date +%H%M%S).log

echo Pre-cleaning
rm -f $log
rm -f *-reader* *-writer*
./run_guest.sh find . -type f -name '*-reader*' -delete
./run_guest.sh find . -type f -name '*-writer*' -delete

echo LOGFILE IS: $log
echo ==========================================

uname -a | tee -a $log
file testbedhdd.img | tee -a $log
echo Guest backend: $backend | tee -a $log
echo $cmd | tee -a $log
echo "Host:" | tee -a $log
$cmd | tee -a $log
echo "Guest:" | tee -a $log
./run_guest.sh $cmd --direct=1 | tee -a $log

echo Post-cleaning
./run_guest.sh find . -type f -name '*-reader*' -delete
./run_guest.sh find . -type f -name '*-writer*' -delete
rm -f *-reader* *-writer*
