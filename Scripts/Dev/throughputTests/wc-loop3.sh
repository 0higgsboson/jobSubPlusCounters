#!/bin/bash

for i in `seq 1 100` ;
do
    echo "submission " $i
    date
    nohup /root/jobSubPlusCounters/Scripts/Dev/throughputTests/wc3.sh > /dev/null 2>&1 &
    sleep 420 
done


