#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/../configurations.sh
source ${CWD}/../utils.sh

PSM=true
workload="NA"
tag="NA"

if [ $# -eq 3 ]
  then
    workload=$1
    PSM=$2
    tag=$3
  else
    echo "Usage: three arguements are required:  workload_name (true|false) Tag"
    echo "true means PSManaged flag will be set, otherwise not"
    exit
fi

printHeader "Running Workload: ${workload}"

cd "${installation_base_dir}/HiBench/workloads/${workload}/mapreduce/bin/"


rm temp.sh
cp run.sh temp.sh

replaceText 'hive -f'  "hive -hiveconf PSManaged=${PSM} -hiveconf Tag=${tag} -f "  temp.sh


./temp.sh
#rm temp.sh

