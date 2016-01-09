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

cd ${installation_base_dir}/HiBench/workloads/kmeans/mapreduce/bin/
rm temp.sh
cp run.sh temp.sh


replaceText 'mahout kmeans'  "mahout kmeans -DPSManaged=${PSM}  -DTag=${tag}" temp.sh


./temp.sh
#rm temp.sh



