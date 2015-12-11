#!/bin/bash
rm -r /opt/sherpa/
mkdir -p /opt/sherpa/
touch /opt/sherpa/SherpaSequenceNos.txt
echo '{"DBInstanceId":2,"MLSeqNoCurrent":1,"description":"Used to tune MR jobs","TenzingList":[]}' >> /opt/sherpa/TenzingDB.txt
echo '{"cfgListCt":{"iterationNumber":0,"workloadID":0,"ConfigList":[]},"test":"xx"}' >> /opt/sherpa/clientDB.txt


hdfs dfs -rm -r /out
yarn jar /root/cluster/hadoop/hadoop-2.6.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar wordcount -D PSManaged=false /normal /out






for i in `seq 1 20`;
  do
    hdfs dfs -rm -r /out
    yarn jar /root/cluster/hadoop/hadoop-2.6.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar wordcount -D PSManaged=false /large /out
  done





hdfs dfs -rm -r /out
yarn jar /root/cluster/hadoop/hadoop-2.6.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar wordcount -D PSManaged=false /normal /out
cat /opt/sherpa/clientDB.txt






hdfs dfs -rm -r /out
yarn jar /root/cluster/hadoop/hadoop-2.6.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar wordcount -D PSManaged=true /large /out
cat /opt/sherpa/clientDB.txt



yarn jar /root/cluster/hadoop/hadoop-2.6.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar terasort -D PSManaged=true /terain /teraout
cat /opt/sherpa/clientDB.txt






hdfs dfs -rm -r /terain
yarn jar /root/cluster/hadoop/hadoop-2.6.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar teragen -D PSManaged=false 10000000 /terain
hdfs dfs -du -h /terain


