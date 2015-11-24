#!/bin/bash

source /etc/environment
source sherpa_configurations.sh


##########################################################   Running MR Client Test    ####################################################################
printHeader "Running MR Client Test"

cd ${mr_client_src_dir}/mrClient

print "Running test ..."
rm /opt/sherpa.properties
echo "
mapreduce.job.reduces=4
threshold=100
 " >> /opt/sherpa.properties

hdfs dfs -mkdir /input
hdfs dfs -copyFromLocal ${sherpa_src_dir}/jobSubPlusCounters/core/src/main/java/com/sherpa/core/dao/WorkloadCountersPhoenixDAO.java /input/

#yarn jar ${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar pi 10 100

hdfs dfs -rm -r /mrTestOutputBySherpa
yarn jar ${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar wordcount -D PSManaged=true /input/ /mrTestOutputBySherpa

