#!/bin/bash -e

dir=$1

if [[ -z "$dir" ]]
then
  echo usage: $0 bench-result-dir
  exit 1
fi

rm -f *.csv
find "$dir" -name "*.log" -exec ./parse.sh {} \;
