#!/bin/bash

#HADOOP_VERSION=2.6.0
HADOOP_VERSION=2.7.1

# For Hadoop version 2.7 use H2.7.1 and for Hadoop 2.6 use H2.6
activeProfile=H2.7.1

#  Configurations
#------------------------------------------------------------
  # define following directories without ending slash /
installation_base_dir=/root/code/sherpa
hive_home=/root/cluster/hive/apache-hive-1.2.1-bin
hadoop_home=/root/cluster/hadoop/hadoop-${HADOOP_VERSION}
scripts_home=/root/scripts
export PATH=$PATH:$hadoop_home/bin

# Define one path according to hadoop version
# For Hadoop 2.7.1
mr_client_src_dir="${installation_base_dir}/mr_client_src/hadoop2.7"
# For Hadoop
#mr_client_src_dir="${installation_base_dir}/mr_client_src/mrClient"


hive_client_src_dir="${installation_base_dir}/hive_client_src"
hadoop_src_dir="${installation_base_dir}/hadoop_src"
sherpa_src_dir="${installation_base_dir}/jobSubPub_src"
common_src_dir="${installation_base_dir}/tzCtCommon"

#------------------------------------------------------------




# Printing Functions
function print(){
  printf "\n"
  echo "$1"
  echo "================================"
}

function printHeader(){
  printf "\n\n"
  echo "**************************************** $1 ***********************************************"
}
