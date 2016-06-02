#!/bin/bash

for i in `seq 1 360` ;
do
    echo "submission " $i
    date
    sleep 35 
    nohup /root/data1/wc-mr-01.sh > /dev/null 2>&1 &
done

