#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/../../configurations.sh
source ${CWD}/../../utils.sh

PSM=true
tag="NA"

if [ $# -eq 4 ]
  then
    PSM=$1
    tag=$2
    costObjective=$3
    queue_name=$4
  else
    echo "Error: number of args did not match"
    exit
fi

cd ${installation_base_dir}/HiBench/workloads/terasort/mapreduce/bin/
rm temp.sh
cp run.sh temp.sh

replaceText 'terasort'  "terasort -D mapreduce.terasort.simplepartitioner=true -D PSManaged=${PSM}  -D Tag=${tag}  -D SherpaCostObj=${costObjective} -D mapreduce.job.queuename=${queue_name} " temp.sh

./temp.sh
#rm temp.sh



