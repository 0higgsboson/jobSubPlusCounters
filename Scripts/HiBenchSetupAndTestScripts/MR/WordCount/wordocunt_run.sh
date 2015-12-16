#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/../configurations.sh
source ${CWD}/../utils.sh

PSM=true
if [ $# -eq 1 ]
  then
    PSM=$1
fi

cd ${installation_base_dir}/HiBench/workloads/wordcount/mapreduce/bin/
rm temp.sh
cp run.sh temp.sh

if [ "$PSM" = "true" ]
then
    replaceText '${INPUT_HDFS} ${OUTPUT_HDFS}'  '-D PSManaged=true ${INPUT_HDFS} ${OUTPUT_HDFS}' temp.sh
else
    replaceText '${INPUT_HDFS} ${OUTPUT_HDFS}'  '-D PSManaged=false ${INPUT_HDFS} ${OUTPUT_HDFS}' temp.sh
fi

./temp.sh
rm temp.sh



