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
costObjective="Memory"


if [ $# -eq 7 ]
  then
    workload=$1
    PSM=$2
    iterations=$3
    tag=$4
    workloadMetaDirectory=$5
    costObjective=$6
    queue_name=$7
  else
    echo "Required Arguements: workload_name (true|false) number_of_iterations  tag  meta_dir cost_objective queue_name"
    exit
fi

outputFile="${installation_base_dir}/HiBench/report/${workload}/mapreduce/bench.log"

printHeader "Running Workload: ${workload} ${iterations} Times ..."
echo "Output File: ${outputFile}"

for i in `seq 1 ${iterations}`;
  do
      print "Iteration $i of $iterations ..."

      rm "${outputFile}"

      if [[ "$workload" = "sort" || "$workload" = "terasort" || "$workload" = "wordcount" || "$workload" = "kmeans" || "$workload" = "bayes" ]]
      then
          ./MR/mr_generic_run.sh $workload  $PSM  $tag  $costObjective   $queue_name
      elif [[ "$workload" = "join" || "$workload" = "scan" || "$workload" = "aggregation" ]]
      then
          ./SQL/sql_generic_run.sh $workload  $PSM $tag  $costObjective  $queue_name
      else
          echo "Possible workload names: ( sort | terasort | wordcount | scan | join | aggregation | kmeans | bayes )"
      fi


     echo "


Iteration: $i PSManaged=${PSM}" >>  "${workloadMetaDirectory}/${log_file}"

     cat "${outputFile}" >>  "${workloadMetaDirectory}/${log_file}"
     cat "${outputFile}" >>  "${workloadMetaDirectory}/${i}_${log_file}"
  done




