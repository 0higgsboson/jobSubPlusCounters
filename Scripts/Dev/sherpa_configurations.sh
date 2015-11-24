#!/bin/bash


#  Configurations
#------------------------------------------------------------
  # define following directories without ending slash /
installation_base_dir=/root/sherpa
hive_home=/root/cluster/hive/apache-hive-1.2.1-bin
hadoop_home=/root/cluster/hadoop/hadoop-2.6.0
scripts_home=/root/scripts
export PATH=$PATH:$hadoop_home/bin

mr_client_src_dir="${installation_base_dir}/mr_client_src"
hive_client_src_dir="${installation_base_dir}/hive_client_src"
hadoop_src_dir="${installation_base_dir}/hadoop_src"
sherpa_src_dir="${installation_base_dir}/jobSubPub_src"

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
