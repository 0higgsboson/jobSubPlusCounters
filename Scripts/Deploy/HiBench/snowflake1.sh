#!/bin/sh

for i in `seq 1 4`;
  do
    cp workload_configurations_pre.sh workload_configurations.sh
    suffix="suffix=05-03-2017-"$1"-"$i
    echo $suffix >> workload_configurations.sh
    ./runWorkload.sh
  done
