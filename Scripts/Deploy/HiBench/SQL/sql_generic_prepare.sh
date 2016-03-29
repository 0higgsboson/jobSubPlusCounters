#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/../configurations.sh
source ${CWD}/../utils.sh

#./cleanup.sh

profile=${data_profile}
workload="na"

if [ $# -eq 2 ]
  then
    workload=$1
    profile=$2
  else
    echo "Usage: two arguements are required:  workload_name data_profile"
    exit
fi


printHeader "Preparing Workload: ${workload}"

cd ${installation_base_dir}/HiBench/

setConfiguration hibench.scale.profile  ${profile} conf/99-user_defined_properties.conf

cd "workloads/${workload}/prepare/"


./prepare.sh

print "Input Data Size :"
name="$(tr '[:lower:]' '[:upper:]' <<< ${workload:0:1})${workload:1}"
hdfs dfs -du -h ${hdfs_master}/HiBench/${name}/Input/