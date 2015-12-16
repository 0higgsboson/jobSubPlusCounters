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

cd "${installation_base_dir}/HiBench/workloads/${workload}/mapreduce/bin/"


rm temp.sh
cp run.sh temp.sh

if [ "$PSM" = "true" ]
then
    replaceText 'hive -f'  'hive -hiveconf PSManaged=true -f '  temp.sh
else
    replaceText 'hive -f'  'hive -hiveconf PSManaged=false -f'  temp.sh
fi

./temp.sh
#rm temp.sh

