#!/bin/bash

source /etc/environment
source sherpa_configurations.sh



##########################################################   Compiling Sherpa Project    ####################################################################
printHeader "Compiling Sherpa Project"

#echo "Sherpa Dir: $sherpa_src_dir/jobSubPlusCounters"
#cd $sherpa_src_dir/jobSubPlusCounters
#mvn clean install -DskipTests -P${activeProfile}


cd ${common_src_dir}/TzCtCommon
mvn clean install -DskipTests -P${activeProfile}



##########################################################   Compiling Hive Client    ####################################################################
printHeader "Compile Hive Client"

echo "Hive Source Dir: $hive_client_src_dir/hiveClientSherpa/"
cd $hive_client_src_dir/hiveClientSherpa
mvn clean package -pl ql,cli  -Phadoop-2  -DskipTests



##########################################################   Deploying Hive Client    ####################################################################
printHeader "Deploying Hive Client"

echo "$hive_client_src_dir/hiveClientSherpa"
cd $hive_client_src_dir/hiveClientSherpa


# Copies custom jars into Hive's lib dir
print "Copying jars into Hive's lib dir ..."

rm ${hive_home}/lib/hive-cli*.jar
rm ${hive_home}/lib/hive-exec*.jar

rm -r /opt/sherpa/lib/*
cp cli/target/hive-cli*.jar /opt/sherpa/lib/
cp ql/target/hive-exec*.jar /opt/sherpa/lib/
cp ${common_src_dir}/TzCtCommon/target/TzCtCommon*jar-with-dependencies.jar /opt/sherpa/lib/TzCtCommon-jar-with-dependencies.jar
