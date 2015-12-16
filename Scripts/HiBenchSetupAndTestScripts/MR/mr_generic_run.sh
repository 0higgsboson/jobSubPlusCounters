#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/../configurations.sh
source ${CWD}/../utils.sh

PSM=true
workload="na"

if [ $# -eq 2 ]
  then
    workload=$1
    PSM=$2
  else
    echo "Usage: two arguements are required:  workload_name (true|false)"
    echo "true means PSManaged flag will be set, otherwise not"
    exit
fi

printHeader "Running Workload: ${workload}"

if [ "$workload" = "sort" ]
then
    ${CWD}/Sort/sort_run.sh  $PSM
elif [ "$workload" = "terasort" ]
then
    ${CWD}/Terasort/terasort_run.sh   $PSM
elif [ "$workload" = "wordcount" ]
then
    ${CWD}/WordCount/wordocunt_run.sh   $PSM
else
    echo "Possible workload names: sort | terasort | wordcount"
fi
