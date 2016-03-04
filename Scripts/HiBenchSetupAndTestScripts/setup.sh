#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source configurations.sh
source utils.sh


# Installs dictionary required by bayes and other workloads
apt-get -y install  wamerican

# Checks hdfs_master variable, exit script if not defined
if [ -z ${hdfs_master} ]; then
	echo "Please set hdfs_master variable"
        exit
fi


# Sets up directories, by default cleans up existing directories
echo "Setting up directories ..."
rm -r ${installation_base_dir}/*
mkdir -p ${installation_base_dir}
cd ${installation_base_dir}


# Clones HiBench Project
echo "git clone https://github.com/intel-hadoop/HiBench.git"
git clone ${hibench_url}
cd HiBench

# Builds the project
echo "Building project ..."
./bin/build-all.sh


# Prepares configuration files
echo "Preparing configuration files ..."
cd conf 
cp "${CWD}"/99-user_defined_properties.conf  99-user_defined_properties.conf


setConfiguration hibench.hadoop.home  "${HADOOP_HOME}" 99-user_defined_properties.conf
setConfiguration hibench.spark.home   "${SPARK_HOME}"  99-user_defined_properties.conf
setConfiguration hibench.hdfs.master  "${hdfs_master}" 99-user_defined_properties.conf

# Removes number of mappers and redcuers settings for hive workloads
sed -i 's~set ${MAP_CONFIG_NAME}=$NUM_MAPS;~~'      "${installation_base_dir}/HiBench/bin/functions/workload-functions.sh"
sed -i 's~set ${REDUCER_CONFIG_NAME}=$NUM_REDS;~~'  "${installation_base_dir}/HiBench/bin/functions/workload-functions.sh"

cd ${CWD}
echo "Finished the Set up of HiBench ..."

