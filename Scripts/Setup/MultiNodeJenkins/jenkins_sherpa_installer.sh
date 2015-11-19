#!/bin/bash

# Assumptions
# 1. Should be run on Jenkin's master node
# 2. Jenkins's Master Node have ssh access to master node


if [ "$#" -ne 2 ]; then
    echo "Usage: master_host script_dir_path"
    echo "Example:"
    echo "./run.sh  master /home/ubuntu/SP/Scripts/Setup/MultiNodeJenkins/"
    exit
fi


# includes configurations
source configurations.sh

# includes utils functions
source utils.sh


master=$1
scripts_dir=$2


sudo apt-get -y install pdsh
export PDSH_RCMD_TYPE=ssh


mkdir -p ${sherpa_repo_dir}/scripts
mkdir -p ${sherpa_repo_dir}/source

cp -r ${scripts_dir}/*   ${sherpa_repo_dir}/scripts/


##########################################################   Cloning Repo's    ####################################################################
printHeader "Cloning Repo's"

cd ${sherpa_repo_dir}/source/

print "Cloning Sherpa Performance Project"
git clone https://github.com/0higgsboson/jobSubPlusCounters.git

print "Cloning custom Hive Code"
git clone https://github.com/0higgsboson/hiveClientSherpa.git

print "Cloning custom MR Code"
git clone https://github.com/0higgsboson/mrClient.git

print "Cloning Hadoop 2.6.0 Code"
if [ ! -f hadoop-2.6.0-src.tar.gz ]; then
    wget https://archive.apache.org/dist/hadoop/core/hadoop-2.6.0/hadoop-2.6.0-src.tar.gz
fi



pdsh -w  ${master}  "apt-get -y install pdsh"
pdsh -w  ${master}  "export PDSH_RCMD_TYPE=ssh"




print "Copying scripts & source codes to ${master} ... "
pdsh -w ${master} "mkdir -p ${sherpa_repo_dir}"

pdcp -r -w ${master}  ${sherpa_repo_dir}/scripts ${sherpa_repo_dir}/
pdcp -r -w ${master}  ${sherpa_repo_dir}/source  ${sherpa_repo_dir}/

ssh root@${master}  " cd ${sherpa_repo_dir}/scripts/ ;
                      ./sherpa_installer.sh"

