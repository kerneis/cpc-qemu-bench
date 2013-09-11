#!/bin/sh -e

rw=$1
jobs=$2
backend=$3

name=bench-$rw

cmd="fio --minimal --name=$name --rw=$rw --bs=1k --runtime=300 --ramp_time=30 --time_based --size=1m --numjobs=$jobs"
logdir=$(date +data/%Y/%m/%d)
log=${logdir}/${name}-${backend}-${jobs}-$(date +%H%M%S).log

echo Pre-cleaning
rm -f $log
rm -f bench-*
./run_guest.sh rm -f 'bench-*'

mkdir -p $logdir

echo LOGFILE IS: $log
echo ==========================================

uname -a >> $log
echo -n "looking for kvm: " >> $log
(lsmod|grep kvm >> $log) || echo "not found" >> $log
file testbedhdd.img >> $log
echo backend: $backend >> $log
echo $cmd >> $log
echo "(adding --direct=1 for guest)" >> $log
echo "Host:" >> $log
#$cmd >> $log
echo skipping >> $log
echo "Guest:" >> $log
./run_guest.sh $cmd --direct=1 >> $log

echo Post-cleaning
rm -f bench-*
./run_guest.sh rm -f 'bench-*'
