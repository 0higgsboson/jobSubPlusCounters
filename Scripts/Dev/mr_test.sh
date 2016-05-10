#!/bin/bash

source /etc/environment
source sherpa_configurations.sh


##########################################################   Running MR Client Test    ####################################################################
printHeader "Running MR Client Test"

cd ${mr_client_src_dir}/

print "Running test ..."


if [ $# -eq 1 ]
  then
    hdfs dfs -rm -r /mrTestOutputBySherpa
    hdfs dfs -mkdir /test
    hdfs dfs -copyFromLocal ${sherpa_src_dir}/jobSubPlusCounters/core/src/main/java/com/sherpa/core/dao/WorkloadCountersPhoenixDAO.java /test/
    yarn jar ${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-examples-${HADOOP_VERSION}.jar wordcount -D PSManaged=true -D SherpaCostObj=Latency /test/ /mrTestOutputBySherpa
  else
    yarn jar ${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-examples-${HADOOP_VERSION}.jar pi -D PSManaged=true -D SherpaCostObj=Latency 5 5
fi





