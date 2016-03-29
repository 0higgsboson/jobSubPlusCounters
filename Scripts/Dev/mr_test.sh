#!/bin/bash

source /etc/environment
source sherpa_configurations.sh


##########################################################   Running MR Client Test    ####################################################################
printHeader "Running MR Client Test"

cd ${mr_client_src_dir}/

print "Running test ..."

hdfs dfs -mkdir /test
hdfs dfs -copyFromLocal ${sherpa_src_dir}/jobSubPlusCounters/core/src/main/java/com/sherpa/core/dao/WorkloadCountersPhoenixDAO.java /test/

#yarn jar ${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar pi 10 100

hdfs dfs -rm -r /mrTestOutputBySherpa
yarn jar ${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-examples-${HADOOP_VERSION}.jar wordcount -D PSManaged=true /test/ /mrTestOutputBySherpa
hdfs dfs -rm -r /mrTestOutputBySherpa

