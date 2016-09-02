#!/bin/bash

for i in `seq 1 10` ;
do
    echo "submission " $i
    date
    nohup /root/jobSubPlusCounters/Scripts/Dev/throughputTests/ts-small-best.sh > /dev/null 2>&1 &
    sleep 1
done

