#!/bin/sh -e

backend=$1

if [ -z "$backend" ]
then
  echo Usage: $0 backend-name
  echo Available backends:
  ls qemu/bin
  exit 1
fi

(pkill qemu-system && echo "Killed QEMU, sleeping 30s" && sleep 30) || true

terminate() {
    echo "Killing QEMU"
    pkill qemu-system || true
    sleep 2
    git add data/
    git commit -m "autocommit bench $backend" data/
    trap - EXIT
    exit 0
}

trap terminate INT QUIT TERM EXIT

echo Starting guest
./start_guest.sh $backend &

echo Sleeping for 2 min
sleep 120

result=`./run_guest.sh echo good || echo fail`
if [ "$result" = "fail" ]; then
  echo Cannot contact guest, sleeping 2 more minutes
  sleep 120
  result=`./run_guest.sh echo good || echo fail`
  if [ "$result" = "fail" ]; then
    echo Guest still unreachable, quit
    exit 1
  fi
fi

echo Guest status: $result

for rw in read write randread randwrite; do
  for job in 100 500; do
    echo TESTING: rw=$rw numjobs=$job backend=$backend
    ./run_fio.sh ${rw} ${job} ${backend}
  done
done
