#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/../../configurations.sh
source ${CWD}/../../utils.sh

PSM=true
tag="NA"

if [ $# -eq 1 ]
  then
    PSM=$1
elif [ $# -eq 2 ]
  then
    PSM=$1
    tag=$2
fi

cd ${installation_base_dir}/HiBench/workloads/terasort/mapreduce/bin/
rm temp.sh
cp run.sh temp.sh

if [ "$PSM" = "true" ]
then
    replaceText 'terasort'  "terasort -D PSManaged=true  -D Tag=${tag}" temp.sh
else
    replaceText 'terasort'  "terasort -D PSManaged=false -D Tag=${tag}" temp.sh
fi

./temp.sh
#rm temp.sh



