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

echo "rm ${hive_home}/lib/hive-cli-1.2.1.jar"
rm ${hive_home}/lib/hive-cli-1.2.1.jar

echo "rm ${hive_home}/lib/hive-exec-1.2.1.jar"
rm ${hive_home}/lib/hive-exec-1.2.1.jar


echo "cp cli/target/hive-cli-1.2.1.jar ${hive_home}/lib/hive-cli-1.2.1.jar"
cp cli/target/hive-cli-1.2.1.jar ${hive_home}/lib/hive-cli-1.2.1.jar

echo "cp ql/target/hive-exec-1.2.1.jar ${hive_home}/lib/hive-exec-1.2.1.jar"
cp ql/target/hive-exec-1.2.1.jar ${hive_home}/lib/hive-exec-1.2.1.jar

echo "cp ${common_src_dir}/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar /root/cluster/hive/apache-hive-1.2.1-bin/lib/"
cp ${common_src_dir}/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar /root/cluster/hive/apache-hive-1.2.1-bin/lib/


cp cli/target/hive-cli-1.2.1.jar /opt/sherpa/lib/
cp ql/target/hive-exec-1.2.1.jar /opt/sherpa/lib/
cp ${common_src_dir}/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar /opt/sherpa/lib/
