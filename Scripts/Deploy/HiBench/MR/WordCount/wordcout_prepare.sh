#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/../../configurations.sh
source ${CWD}/../../utils.sh

profile=${data_profile}

if [ $# -eq 1 ]
  then
    profile=$1
fi



cd ${installation_base_dir}/HiBench/

setConfiguration hibench.scale.profile  ${profile} conf/99-user_defined_properties.conf

cd workloads/wordcount/prepare/

./prepare.sh