#!/bin/bash

source /etc/environment
source sherpa_configurations.sh



##########################################################   Compiling Sherpa Project    ####################################################################
printHeader "Compiling Sherpa Project"

#cd $sherpa_src_dir/jobSubPlusCounters
#mvn clean install -DskipTests -P${activeProfile}


cd ${common_src_dir}/TzCtCommon
mvn clean install -DskipTests   -P${activeProfile}


##########################################################   Compiling MR Client    ####################################################################
printHeader "Compiling MR Client"

cd ${mr_client_src_dir}/
mvn clean package -Pdist -DskipTests


##########################################################   Deploying MR Client    ####################################################################
printHeader "Deploying MR Client"


cd ${mr_client_src_dir}/

print "Copying Jars ..."
cp ${mr_client_src_dir}/target/hadoop-mapreduce-client-core-${HADOOP_VERSION}.jar /opt/sherpa/lib/
cp ${common_src_dir}/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar /opt/sherpa/lib/