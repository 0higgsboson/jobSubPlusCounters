#!/bin/bash

source $1

for i in `seq 1 $nodes`;
  do
    if [ $i -lt 10 ]; then
        str="0"
    else
        str=""
    fi
    hostname=$cluster-$str$i
    azure vm delete -q -g $group -n $hostname
  done
