#!/bin/bash

for i in `seq 1 100` ;
do
    echo "submission " $i
    date
    if (( $i%10 == 1)) 
    then 
      nohup /root/jobSubPlusCounters/Scripts/Dev/throughputTests/wc1.sh > /dev/null 2>&1 &
      echo "Unmanaged"
    else
      nohup /root/jobSubPlusCounters/Scripts/Dev/throughputTests/wc2.sh > /dev/null 2>&1 &
      echo "Managed"
    fi
    sleep 420 
done


