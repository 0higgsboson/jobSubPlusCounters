#!/bin/bash

numParallelJobs=4
numItersMax=120
sleepSeconds=3
sleepWaitForJobSubmission=20
sleepBetweenRuns=600

i=0

echo 
echo numParallelJobs = $numParallelJobs
echo numItersMax = $numItersMax
echo sleepSeconds = $sleepSeconds
echo sleepWaitForJobSubmission = $sleepWaitForJobSubmission
echo sleepBetweenRuns = $sleepBetweenRuns
echo

# sleep 400 # $sleepBetweenRuns

# cp join.sql join$i.sql
#sed -i "s/RUJ/RUJ$i/g" join$i.sql
# exit;

while true; do

  yarn application -list > tmp.txt
  sparkAppCount=$(cat tmp.txt | grep SPARK | wc -l)
  echo count is $sparkAppCount num parallel jobs is $numParallelJobs i = $i

  if (($sparkAppCount < $numParallelJobs)); then
    echo Submitting job wait for $sleepWaitForJobSubmission seconds for job to be submitted before polling

    cp join.sql todelete/join$i.sql
    sed -i "s/RUJ/RUJ$i/g" todelete/join$i.sql

    cp submitJoinCleanupAfter.sh todelete/submitJoinCleanupAfter$i.sh
    sed -i "s/XXX/$i/g" todelete/submitJoinCleanupAfter$i.sh

    nohup todelete/submitJoinCleanupAfter$i.sh &
    sleep $sleepWaitForJobSubmission

    i=$[$i+1]

    if (($i >= $numItersMax)); then
      break;
    fi
  fi

  date
  sleep $sleepSeconds

done;


sleep $sleepBetweenRuns


i=0

while true; do

  yarn application -list > tmp.txt
  sparkAppCount=$(cat tmp.txt | grep SPARK | wc -l)
  echo count is $sparkAppCount num parallel jobs is $numParallelJobs i = $i

  if (($sparkAppCount < $numParallelJobs)); then

    echo Submitting job wait for $sleepWaitForJobSubmission seconds for job to be submitted before polling

    cp join.sql todelete/join$i.sql
    sed -i "s/RUJ/RUJ$i/g" todelete/join$i.sql
    
    cp submitJoinCleanupAfterTuned.sh todelete/submitJoinCleanupAfterTuned$i.sh
    sed -i "s/XXX/$i/g" todelete/submitJoinCleanupAfterTuned$i.sh

    nohup todelete/submitJoinCleanupAfterTuned$i.sh &
    sleep $sleepWaitForJobSubmission

    i=$[$i+1]
  
    if (($i >= $numItersMax)); then
      break;
    fi
  fi

  date
  sleep $sleepSeconds

done;

# mv submitJoinCleanupAfter* todelete/
# mv join*sql todelete
# cp todelete/join.sql .
mv floodSparkWJoin.*.log todelete/

exit;


