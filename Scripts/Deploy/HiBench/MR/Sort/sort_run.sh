#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/../../configurations.sh
source ${CWD}/../../utils.sh

PSM=true
tag="NA"

if [ $# -eq 3 ]
  then
    PSM=$1
    tag=$2
    costObjective=$3
  else
    echo "Error: number of args not match"
    exit
fi

cd ${installation_base_dir}/HiBench/workloads/sort/mapreduce/bin/
rm temp.sh
cp run.sh temp.sh

if [ "$PSM" = "true" ]
then
    replaceText 'sort'  "sort -D PSManaged=true -D Tag=${tag}  -D SherpaCostObj=${costObjective} " temp.sh
else
    replaceText 'sort'  "sort -D PSManaged=false -D Tag=${tag}  -D SherpaCostObj=${costObjective} " temp.sh
fi

./temp.sh
#rm temp.sh


