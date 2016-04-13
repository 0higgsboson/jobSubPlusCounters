#!/bin/bash

#
# Installs MR & Hive Clients Jars
#


#
# Mandatory Configurations
#--------------------------------------------------------------------------------------------------------------------
HADOOP_VERSION=2.7.1
HIVE_VERSION=1.2.1
HADOOP_LIB_DIR=/root/cluster/hadoop/hadoop-2.7.1/share/hadoop/mapreduce/lib/
HIVE_LIB_DIR=/root/cluster/hive/apache-hive-1.2.1-bin/lib/
#--------------------------------------------------------------------------------------------------------------------


#
# Sherpa Configurations
#--------------------------------------------------------------------------------------------------------------------
SHERPA_COMMON_JAR_NAME=TzCtCommon-1.0-jar-with-dependencies.jar
SHERPA_MR_JAR_NAME=hadoop-mapreduce-client-core-${HADOOP_VERSION}.jar
SHERPA_HIVE_CLI_JAR_NAME=hive-cli-${HIVE_VERSION}.jar
SHERPA_HIVE_EXEC_JAR_NAME=hive-exec-${HIVE_VERSION}.jar
SHERPA_PROPERTY_FILE=sherpa.properties
#--------------------------------------------------------------------------------------------------------------------


#
# Checks file exists, exits script on file not found
# Takes file path as arguement
#
function fileExists(){
    file=$1
    if [ ! -f  "${file}" ];
    then
        echo "Error: file ${file} does not exist."
        exit
    fi
}

fileExists  $SHERPA_COMMON_JAR_NAME
fileExists  $SHERPA_MR_JAR_NAME
fileExists  $SHERPA_HIVE_CLI_JAR_NAME
fileExists  $SHERPA_HIVE_EXEC_JAR_NAME
fileExists  $SHERPA_PROPERTY_FILE


echo "Deploying MR Client ..."
cp ${SHERPA_MR_JAR_NAME}             ${HADOOP_LIB_DIR}/
cp ${SHERPA_COMMON_JAR_NAME}         ${HADOOP_LIB_DIR}/
cp ${SHERPA_PROPERTY_FILE}           "/opt/sherpa.properties"
echo "Done Deploying MR Client ..."


echo "Deploying Hive Client ..."
cp ${SHERPA_HIVE_CLI_JAR_NAME}             ${HIVE_LIB_DIR}/
cp ${SHERPA_HIVE_EXEC_JAR_NAME}            ${HIVE_LIB_DIR}/
cp ${SHERPA_COMMON_JAR_NAME}               ${HIVE_LIB_DIR}/
echo "Done Deploying Hive Client ..."
