#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/configurations.sh
source ${CWD}/utils.sh


workload="na"
PSM=true
iterations=20
tag="NA"

if [ $# -eq 3 ]
  then
    workload=$1
    PSM=$2
    iterations=$3
elif [ $# -eq 4 ]
  then
    workload=$1
    PSM=$2
    iterations=$3
    tag=$4
  else
    echo "Arguements: workload_name (true|false) number_of_iterations [optional tag]"
    echo "true sets PSManged flag"
    exit
fi

printHeader "Running Workload: ${workload} ${iterations} Times ..."

createLearningConfgis 4


for i in `seq 1 ${iterations}`;
  do
      print "Iteration $i of $iterations ..."

      if [[ "$workload" = "sort" || "$workload" = "terasort" || "$workload" = "wordcount" || "$workload" = "kmeans" || "$workload" = "bayes" ]]
      then
          #./MR/mr_generic_run.sh $workload  $PSM  $tag
          ./MR/mr_generic_run.sh $workload  false  $tag
          ./MR/mr_generic_run.sh $workload  true   $tag
      elif [[ "$workload" = "join" || "$workload" = "scan" || "$workload" = "aggregation" ]]
      then
          ./SQL/sql_generic_run.sh $workload  $PSM
      else
          echo "Possible workload names: sort | terasort | wordcount | scan | join | aggregation"
      fi
  done




