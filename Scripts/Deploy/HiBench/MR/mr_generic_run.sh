#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/../configurations.sh
source ${CWD}/../utils.sh

PSM=true
workload="na"
tag="NA"
costObjective="Memory"

if [ $# -eq 5 ]
  then
    workload=$1
    PSM=$2
    tag=$3
    costObjective=$4
    queue_name=$5
  else
    echo "Usage: five arguements are required:  workload_name (true|false) tag cost_objective  queue_name"
    echo "true means PSManaged flag will be set, otherwise not"
    exit
fi

printHeader "Running Workload: ${workload}"

if [ "$workload" = "sort" ]
then
    ${CWD}/Sort/sort_run.sh  $PSM $tag  ${costObjective}    ${queue_name}
elif [ "$workload" = "terasort" ]
then
    ${CWD}/Terasort/terasort_run.sh   $PSM  $tag   ${costObjective}   ${queue_name}
elif [ "$workload" = "wordcount" ]
then
    ${CWD}/WordCount/wordocunt_run.sh   $PSM  $tag  ${costObjective}    ${queue_name}
elif [ "$workload" = "kmeans" ]
then
    ${CWD}/KMeans/kmeans_run.sh   $PSM  $tag   ${costObjective}    ${queue_name}
elif [ "$workload" = "bayes" ]
then
    ${CWD}/Bayes/bayes_run.sh   $PSM  $tag   ${costObjective}    ${queue_name}
else
    echo "Possible workload names: sort | terasort | wordcount"
fi
