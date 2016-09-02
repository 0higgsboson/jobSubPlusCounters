#!/bin/sh

for i in `seq 1 10`;
  do
    cp workload_configurations_pre.sh workload_configurations.sh
    suffix="suffix=08-26-2016-"$i
    echo $suffix >> workload_configurations.sh
    ./runWorkload.sh
  done
