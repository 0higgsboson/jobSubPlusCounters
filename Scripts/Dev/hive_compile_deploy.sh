#!/bin/bash

source /etc/environment
source sherpa_configurations.sh



##########################################################   Compiling Sherpa Project    ####################################################################
printHeader "Compiling Sherpa Project"

cd $sherpa_src_dir/jobSubPlusCounters
mvn clean install -DskipTests



##########################################################   Compiling Hive Client    ####################################################################
printHeader "Compile Hive Client"

cd $hive_client_src_dir/hiveClientSherpa
mvn clean install -pl ql,cli  -Phadoop-2  -DskipTests



##########################################################   Deploying Hive Client    ####################################################################
printHeader "Deploying Hive Client"

cd $hive_client_src_dir/hiveClientSherpa


# Copies custom jars into Hive's lib dir
print "Copying jars into Hive's lib dir ..."
cp cli/target/hive-cli-1.2.1.jar ${hive_home}/lib/hive-cli-1.2.1.jar
cp ql/target/hive-exec-1.2.1.jar ${hive_home}/lib/hive-exec-1.2.1.jar
cp $sherpa_src_dir/jobSubPlusCounters/tunecore/target/tunecore-1.0-jar-with-dependencies.jar  ${hive_home}/lib/tunecore-1.0-SNAPSHOT-jar-with-dependencies.jar

