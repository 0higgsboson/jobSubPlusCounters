#!/bin/bash

source /etc/environment
source sherpa_configurations.sh



##########################################################   Compiling Sherpa Project    ####################################################################
printHeader "Compiling Sherpa Project"

cd $sherpa_src_dir/jobSubPlusCounters
mvn clean install -DskipTests


##########################################################   Compiling MR Client    ####################################################################
printHeader "Compiling MR Client"

cd ${mr_client_src_dir}/mrClient
mvn clean install -Pdist -DskipTests


##########################################################   Deploying MR Client    ####################################################################
printHeader "Deploying MR Client"


cd ${mr_client_src_dir}/mrClient

print "Copying Jars ..."
cp ${mr_client_src_dir}/mrClient/target/hadoop-mapreduce-client-core-2.6.0.jar ${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.6.0.jar
cp ${sherpa_src_dir}/jobSubPlusCounters/tunecore/target/tunecore-1.0-jar-with-dependencies.jar ${hadoop_home}/share/hadoop/mapreduce/lib/
