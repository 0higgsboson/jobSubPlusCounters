#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/configurations.sh
source ${CWD}/utils.sh

costObjective=("Memory" "CPU" "Latency" "Throughput")
#workloads=("sort" "wordcount" "kmeans" "bayes")
workloads=("join" "scan" "aggregation")
dataProfile=10M

for c in "${costObjective[@]}"
do
   printHeader "Using Cost Objective: $c"
   createLearningConfigurations "$c"

   for w in "${workloads[@]}"
   do
      iterations=50

      if [[ "${w}" = "kmeans" || "${w}" = "bayes" ]]
      then
          iterations=10
      fi

        tag="${w}_${c}_${dataProfile}"
        print ${tag}
        ./iterativeRun.sh "${w}" false 1 "${tag}"
        ./iterativeRun.sh "${w}" true "${iterations}" "${tag}"

   done


done