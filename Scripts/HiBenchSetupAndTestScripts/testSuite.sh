#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/configurations.sh
source ${CWD}/utils.sh

costObjective=("Memory")
#costObjective=("Memory" "CPU" "Latency" "Throughput")

#workloads=("sort" "wordcount" "kmeans" "bayes" "join" "scan" "aggregation")
workloads=("kmeans" "bayes" "join" "scan" "aggregation")

dataProfile=1GB
prefix=sp

for c in "${costObjective[@]}"
do
   printHeader "Using Cost Objective: $c"
   # to do
   # add workload name too in backup folder name
   createLearningConfigurations "$c"

   for w in "${workloads[@]}"
   do
      iterations=50

      if [[ "${w}" = "kmeans" || "${w}" = "bayes" ]]
      then
          iterations=10
      fi

        tag="${prefix}_${w}_${c}_${dataProfile}"
        print ${tag}
        ./iterativeRun.sh "${w}" false 1 "${tag}"
        ./iterativeRun.sh "${w}" true "${iterations}" "${tag}"

   done


done