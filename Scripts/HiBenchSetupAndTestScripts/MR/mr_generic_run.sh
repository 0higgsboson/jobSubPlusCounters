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

if [ $# -eq 2 ]
  then
    workload=$1
    PSM=$2
elif [ $# -eq 3 ]
  then
    workload=$1
    PSM=$2
    tag=$3
  else
    echo "Usage: two arguements are required:  workload_name (true|false) [optional tag]"
    echo "true means PSManaged flag will be set, otherwise not"
    exit
fi

printHeader "Running Workload: ${workload}"

if [ "$workload" = "sort" ]
then
    ${CWD}/Sort/sort_run.sh  $PSM $tag
elif [ "$workload" = "terasort" ]
then
    ${CWD}/Terasort/terasort_run.sh   $PSM  $tag
elif [ "$workload" = "wordcount" ]
then
    ${CWD}/WordCount/wordocunt_run.sh   $PSM  $tag
elif [ "$workload" = "kmeans" ]
then
    ${CWD}/KMeans/kmeans_run.sh   $PSM  $tag
elif [ "$workload" = "bayes" ]
then
    ${CWD}/Bayes/bayes_run.sh   $PSM  $tag
else
    echo "Possible workload names: sort | terasort | wordcount"
fi
