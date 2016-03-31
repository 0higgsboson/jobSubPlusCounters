#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/../../configurations.sh
source ${CWD}/../../utils.sh

# Fix: https://github.com/intel-hadoop/HiBench/issues/112
export MAHOUT_RELEASE=mahout-0.9-cdh5.1.0
export MAHOUT_EXAMPLE_JOB="mahout-examples-0.9-cdh5.1.0-job.jar"


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

cd ${installation_base_dir}/HiBench/workloads/bayes/mapreduce/bin/
rm temp.sh
cp run.sh temp.sh

if [ "$PSM" = "true" ]
then
    #replaceText 'mahout seq2sparse'  "mahout seq2sparse -DPSManaged=true  -DTag=${tag}" temp.sh
    replaceText 'mahout trainnb'  "mahout trainnb -DPSManaged=true  -DTag=${tag}    -DSherpaCostObj=${costObjective}" temp.sh
else
    #replaceText 'mahout seq2sparse'  "mahout seq2sparse -DPSManaged=false  -DTag=${tag}" temp.sh
    replaceText 'mahout trainnb'  "mahout trainnb -DPSManaged=false  -DTag=${tag}   -DSherpaCostObj=${costObjective}" temp.sh
fi

./temp.sh
#rm temp.sh



