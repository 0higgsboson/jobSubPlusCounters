#!/bin/bash

for i in `seq 1 200` ;
do
    echo "submission " $i
    date
    sleep 9
    nohup /root/jobSubPlusCounters/Scripts/Dev/throughputTests/wc-mr-01.sh > /dev/null 2>&1 &
done

