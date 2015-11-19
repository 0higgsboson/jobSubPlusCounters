#!/bin/bash

# Common Configurations
installation_base_dir=/root
scripts_dir="${installation_base_dir}/scripts/"

# keeps scripts and downloads on jenkin's host
sherpa_repo_dir=/root/sherpa_repo



# Hadoop Configurations
HADOOP_VERSION=2.6.0
yarn_data_dir=/mnt/yarn
hadoop_dir="${installation_base_dir}/cluster/hadoop/"

# Hbase Configurations
HBASE_VERSION=1.0.2
hbase_data_dir=/mnt/hbase
hbase_dir="${installation_base_dir}/cluster/hbase/"


# Phoenix Configurations
PHOENIX_VERSION=4.5.2
phoenix_dir="${installation_base_dir}/cluster/phoenix/"


# Hive Configurations
HIVE_VERSION=1.2.1
hive_dir="${installation_base_dir}/cluster/hive/"


# Spark Configurations
SPARK_VERSION=1.5.1
spark_dir="${installation_base_dir}/cluster/spark/"