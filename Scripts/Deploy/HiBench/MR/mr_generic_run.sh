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

if [ $# -eq 4 ]
  then
    workload=$1
    PSM=$2
    tag=$3
    costObjective=$4
  else
    echo "Usage: four arguements are required:  workload_name (true|false) tag cost_objective"
    echo "true means PSManaged flag will be set, otherwise not"
    exit
fi

printHeader "Running Workload: ${workload}"

if [ "$workload" = "sort" ]
then
    ${CWD}/Sort/sort_run.sh  $PSM $tag  ${costObjective}
elif [ "$workload" = "terasort" ]
then
    ${CWD}/Terasort/terasort_run.sh   $PSM  $tag   ${costObjective}
elif [ "$workload" = "wordcount" ]
then
    ${CWD}/WordCount/wordocunt_run.sh   $PSM  $tag  ${costObjective}
elif [ "$workload" = "kmeans" ]
then
    ${CWD}/KMeans/kmeans_run.sh   $PSM  $tag   ${costObjective}
elif [ "$workload" = "bayes" ]
then
    ${CWD}/Bayes/bayes_run.sh   $PSM  $tag   ${costObjective}
else
    echo "Possible workload names: sort | terasort | wordcount"
fi
