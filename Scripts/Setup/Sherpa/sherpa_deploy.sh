#!/bin/bash

# Assumptions
# 1. Use root account
# 2. Run source /etc/environment to initialize $X_HOME variables.
# 3. Copy ssh public key into github


source /etc/environment
source sherpa_configurations.sh




##########################################################   Deploying Hive Client    ####################################################################
printHeader "Deploying Hive Client"

cd $hive_client_src_dir/hiveClientSherpa


# Copies custom jars into Hive's lib dir
print "Copying jars into Hive's lib dir ..."
cp cli/target/hive-cli-1.2.1.jar ${hive_home}/lib/hive-cli-1.2.1.jar
cp ql/target/hive-exec-1.2.1.jar ${hive_home}/lib/hive-exec-1.2.1.jar
cp $sherpa_src_dir/jobSubPlusCounters/tunecore/target/tunecore-1.0-jar-with-dependencies.jar  ${hive_home}/lib/tunecore-1.0-SNAPSHOT-jar-with-dependencies.jar



##########################################################   Deploying MR Client    ####################################################################
printHeader "Deploying MR Client"


cd ${mr_client_src_dir}/mrClient


print "Stopping Hadoop services ..."
${scripts_home}/hadoop_stop.sh

print "Copying Jars ..."
cp ${mr_client_src_dir}/mrClient/target/hadoop-mapreduce-client-core-2.6.0.jar ${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.6.0.jar
cp ${sherpa_src_dir}/jobSubPlusCounters/tunecore/target/tunecore-1.0-jar-with-dependencies.jar ${hadoop_home}/share/hadoop/mapreduce/lib/

print "Starting Hadoop services ..."
${scripts_home}/hadoop_start.sh

