#!/bin/bash

iters=30

now=$(date +"%Y_%d_%m_%H_%M_%S")
output_file="out-ts-loop-small-default-then-best-"${now}".txt"
echo "# of iterations: "$iters > ${output_file}

function wait_until_no_jobs() {
    while [ `(hadoop job -list 2>/dev/null | grep 'Total jobs' | awk -F : '{print $2;}')` -eq "0" ]
      do
        sleep 1
      done
    while [ `(hadoop job -list 2>/dev/null | grep 'Total jobs' | awk -F : '{print $2;}')` -ne "0" ]
      do
        sleep 1
      done
}


echo "Starting to run $iters default jobs"
default_jobs_start_time=$(date +"%Y_%d_%m_%H_%M_%S")

for i in `seq 1 ${iters}` ;
do
    echo "submission " $i
    date
    nohup ./ts-small-default.sh > /dev/null 2>&1 &
    sleep 1
done

wait_until_no_jobs
default_jobs_end_time=$(date +"%Y_%d_%m_%H_%M_%S")

echo "Default Jobs Start Time: "$default_jobs_start_time >> ${output_file}
echo "Default Jobs End Time: "$default_jobs_end_time >> ${output_file}

echo "Default jobs finished"

echo "Starting to run $iters best jobs"

best_jobs_start_time=$(date +"%Y_%d_%m_%H_%M_%S")
for i in `seq 1 ${iters}` ;
do
    echo "submission " $i
    date
    nohup ./ts-small-best.sh > /dev/null 2>&1 &
    sleep 1
done
wait_until_no_jobs
best_jobs_end_time=$(date +"%Y_%d_%m_%H_%M_%S")

echo "Best jobs finished"
echo "Best Jobs Start Time: "$best_jobs_start_time >> ${output_file}
echo "Best Jobs End Time: "$best_jobs_end_time >> ${output_file}

