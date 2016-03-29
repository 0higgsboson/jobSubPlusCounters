#!/bin/bash

#======================================================
# Mandatory settings
#======================================================
# HDFS namenode, change host and port as per your environment
hdfs_master=hdfs://master:9000/
HADOOP_VERSION=2.7.1
# Chnage hibench.hadoop.home in 99-user_defined_properties.conf file


#======================================================
# Not mandatory but important settings
#======================================================
hibench_url=https://github.com/intel-hadoop/HiBench.git
data_profile=tiny
installation_base_dir=/root/HiBench/
backup_base_dir=/root/MetaData_HiBench
log_file=std_out_err.txt
tmp_path=/var/tmp/hibench

#======================================================
# Default settings
#======================================================
JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
HADOOP_HOME=/root/cluster/hadoop//hadoop-${HADOOP_VERSION}/
HIVE_HOME=/root/cluster/hive//apache-hive-1.2.1-bin/
SPARK_HOME=/root/cluster/spark//spark-1.5.1-bin-hadoop2.6/


