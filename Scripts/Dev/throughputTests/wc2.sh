#!/bin/bash

now=$(date +"%Y_%d_%m_%H_%M_%s")
examplesJar="/root/cluster/hadoop/hadoop-2.7.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar"
# yarn jar /root/sherpa-old/hadoop_src/hadoop-2.7.1-src/hadoop-mapreduce-project/target/hadoop-mapreduce-2.7.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar wordcount -D PSManaged=true -D Tag=wordcount-MR-example-0075 /input/ /output/$now 
yarn jar $examplesJar wordcount -D PSManaged=true -D Tag=wordcount-MR-example-024 /holmesinput/ /holmesoutput/$now 
hadoop fs -rm /holmesoutput/$now/*

