#!/bin/bash

# Assumptions
# 1. Uses jenkins account
#

installation_base_dir=~jenkins/jobs/Sherpa/workspace
hadoop_dir=$installation_base_dir/hadoop
HADOOP_VERSION=2.6.0

mkdir $hadoop_dir
cd $hadoop_dir
rm hadoop-${HADOOP_VERSION}.tar.gz
wget https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
tar -xzf hadoop-${HADOOP_VERSION}.tar.gz
