#!/bin/bash

source ./configs.sh
source ./submitWorkload.sh

echo numDefaultRunsMax $numDefaultRunsMax sleepBetweenRuns $sleepBetweenRuns sleepSeconds $sleepSeconds numItersMax $numItersMax sleepSeconds $sleepSeconds

numRuns=$(( 3 * 1 * $numSnowflakeRuns *($numDefaultRunsMax*2 + $numItersMax) ))
echo numRuns = $numRuns

waitTimePerRun=$(( 2 * $numDefaultRunsMax * $sleepBetweenRuns + 2 * $sleepSeconds + $numItersMax * $sleepSeconds ))
waitTimeHoursTotal=$(( 3 * 1 * $numSnowflakeRuns * $waitTimePerRun / 60/60 ))
echo waitTimeHoursTotal = $waitTimeHoursTotal

numRunsCompleted=0

# exit

for workload in "join" "scan" "aggregation"; # "join";
do

for co in "CPU"; # "Memory" "Latency" "CPU";
do
  for j in `seq 1 $numSnowflakeRuns` ; do

    tag=$workload-$co-$size-$suffix-$j

    for i in `seq 1 $numDefaultRunsMax` ; do 
	submit_workload "Before training" false $workload.sql
        sleep $sleepBetweenRuns;
    done

    sleep $sleepSeconds;

    for i in `seq 1 $numItersMax` ; do 
	submit_workload "Training" true $workload.sql
        if (($i%$batchSizeJobs == 0)); then
          sleep $sleepSeconds;
          continue;
        fi
        sleep $sleepBetweenRuns;
    done

    sleep $sleepSeconds;

    for i in `seq 1 $(( numDefaultRunsMax*10 ))` ; do
	submit_workload "After training" false $workload.sql
        sleep $sleepBetweenRuns;
    done

    sleep $sleepWaitForJobSubmission;

  done

done

done


