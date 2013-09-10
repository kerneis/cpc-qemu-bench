#!/bin/bash -e

file=$1
rw=`egrep --only rw=[[:alpha:]]+ $file | cut -d= -f2`
numjobs=`egrep --only numjobs=[[:digit:]]+ $file | cut -d= -f2`
backend=`grep backend: $file |cut -d\  -f2`

echo $rw $numjobs $backend

output=$rw-$backend

header="backend,numjobs,jobname,groupid,error\
,read.io,read.bw,read.iops,read.runtime\
,read.lat.min,read.lat.max,read.lat.mean,read.lat.sd\
,read.clat.min,read.clat.max,read.clat.mean,read.clat.sd\
,,,,,,,,,,,,,,,,,,,,\
,read.tlat.min,read.tlat.max,read.tlat.mean,read.tlat.sd\
,read.bw.min,read.bw.max,read.bw.taggr,read.bw.mean,read.bw.sd\
,write.io,write.bw,write.iops,write.runtime\
,write.lat.min,write.lat.max,write.lat.mean,write.lat.sd\
,write.clat.min,write.clat.max,write.clat.mean,write.clat.sd\
,,,,,,,,,,,,,,,,,,,,\
,write.tlat.min,write.tlat.max,write.tlat.mean,write.tlat.sd\
,write.bw.min,write.bw.max,write.bw.taggr,write.bw.mean,write.bw.sd\
,user,sys,switches,maj.fault,min.fault\
,depth.1,depth.2,depth.4,depth.8,depth.16,depth.32,depth.64\
,lat.2us,lat.4us,lat.10us,lat.20us,lat.50us,lat.100us,lat.250us,lat.500us,lat.750us,lat.1000us\
,lat.2ms,lat.4ms,lat.10ms,lat.20ms,lat.50ms,lat.100ms,lat.250ms,lat.500ms,lat.750ms,lat.1000ms\
,lat.2000ms,lat.2000plusms\
,,,,,,,,\
,,,,,,,,\
,,,,,,,,\
,,,,,,,,\
"

if [[ ! -e $output-guest.csv ]]
then
  echo $header > $output-guest.csv
fi

#if [[ ! -e $output-host.csv ]]
#then
#  echo $header > $output-host.csv
#fi

egrep "^3;2.0.8;" $file |sed "s/^3;2.0.8;/${backend};${numjobs};/"|sed "s/;/,/g" >> $output-guest.csv
#egrep "^3;fio-2.1.1;" $file |sed "s/^3;fio-2.1.1;/${backend};${numjobs};/" | sed "s/;/,/g" >> $output-host.csv
