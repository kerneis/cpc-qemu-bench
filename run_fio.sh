#!/bin/bash -e

rw=$1
jobs=$2
backend=$3

name=bench-$rw

cmd="fio --minimal --name=$name --rw=$rw --bs=32k --runtime=30 --ramp_time=15 --time_based --size=100m --numjobs=$jobs"
logdir=$(date +data/%Y/%m/%d)
log=${logdir}/${name}-${backend}-${jobs}-$(date +%H%M%S).log

echo Pre-cleaning
rm -f $log
rm -f bench-*
./run_guest.sh rm -f 'bench-*'

mkdir -p $logdir

echo LOGFILE IS: $log
echo ==========================================

uname -a | tee -a $log
echo -n looking for kvm:|tee -a $log
lsmod|grep kvm|tee -a $log
echo . |tee -a $log
file testbedhdd.img | tee -a $log
echo backend: $backend | tee -a $log
echo $cmd | tee -a $log
echo "(adding --direct=1 for guest)"
echo
echo "Host:" | tee -a $log
$cmd | tee -a $log
echo
echo "Guest:" | tee -a $log
./run_guest.sh $cmd --direct=1 | tee -a $log

echo Post-cleaning
rm -f bench-*
./run_guest.sh rm -f 'bench-*'
