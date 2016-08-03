#!/bin/bash

for i in `seq 1 10` ;
do
    echo "submission " $i
    date
    nohup /root/jobSubPlusCounters/Scripts/Dev/throughputTests/ts1.sh > /dev/null 2>&1 &
    sleep 10
done

