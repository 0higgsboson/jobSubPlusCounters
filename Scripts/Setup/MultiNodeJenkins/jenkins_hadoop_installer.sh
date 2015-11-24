#!/bin/bash

# Assumptions
# 1. Should be run on Jenkin's master node
# 2. Jenkins's Master Node have ssh access to master node
# 3. Host file should be named as "hosts"  e.g. /somepath.../hosts   (its required as we need to access that file by name on master node)

if [ "$#" -ne 2 ]; then
    echo "Usage: hosts_file_path script_dir_path"
    echo "Example:"
    echo "./jenkins_hadoop_installer.sh  /root/hosts /home/ubuntu/SP/Scripts/Setup/MultiNodeJenkins/"
    exit
fi


# includes configurations
source configurations.sh

# includes utils functions
source utils.sh


# defines hosts_file and master variables
setupMasterNode "$1"
scripts_dir=$2


sudo apt-get -y install pdsh
export PDSH_RCMD_TYPE=ssh

mkdir -p ${sherpa_repo_dir}/scripts
mkdir -p ${sherpa_repo_dir}/downloads

cp -r ${scripts_dir}/*   ${sherpa_repo_dir}/scripts/
cp  ${hosts_file}   ${sherpa_repo_dir}/scripts/



cd ${sherpa_repo_dir}/downloads/

print "Downloading Hadoop ${HADOOP_VERSION} ..."
if [ ! -f hadoop-${HADOOP_VERSION}.tar.gz ]; then
    wget https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
fi


print "Downloading Hbase ${HBASE_VERSION} ..."
if [ ! -f hbase-${HBASE_VERSION}-bin.tar.gz ]; then
    wget https://www.apache.org/dist/hbase/hbase-${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz --no-check-certificate
fi


print "Downloading Apache Hive ${HIVE_VERSION} ..."
if [ ! -f apache-hive-${HIVE_VERSION}-bin.tar.gz ]; then
    wget http://www.eu.apache.org/dist/hive/stable/apache-hive-${HIVE_VERSION}-bin.tar.gz
fi


print "Downloading Phoenix ${PHOENIX_VERSION} ..."
if [ ! -f phoenix-${PHOENIX_VERSION}-HBase-1.0-bin.tar.gz ]; then
    wget http://www.eu.apache.org/dist/phoenix/phoenix-${PHOENIX_VERSION}-HBase-1.0/bin/phoenix-${PHOENIX_VERSION}-HBase-1.0-bin.tar.gz
fi


print "Downloading Apache Spark ${SPARK_VERSION} ..."
if [ ! -f spark-${SPARK_VERSION}-bin-hadoop2.6.tgz ]; then
    wget http://www.eu.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.6.tgz
fi


pdsh -w  ${master}  "apt-get -y install pdsh"
pdsh -w  ${master}  "export PDSH_RCMD_TYPE=ssh"


print "Copying downloads & scripts to ${master} ... "
pdsh -w ${master} "mkdir -p ${sherpa_repo_dir}"
pdcp -r -w ${master}  ${sherpa_repo_dir}/*  ${sherpa_repo_dir}/


ssh root@${master}  " cd ${sherpa_repo_dir}/scripts/ ;
                      ./install_all.sh ${sherpa_repo_dir}/scripts/hosts"








