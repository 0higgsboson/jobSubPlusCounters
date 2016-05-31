#!/bin/bash

#
# Installs MR & Hive Clients Jars
#


#
# Mandatory Configurations
#--------------------------------------------------------------------------------------------------------------------
# Write permissions required on following dir for current user, read permissions should be granted to Hadoop user
INSTALL_DIR=/opt/sherpa/lib/
#--------------------------------------------------------------------------------------------------------------------


#
# Sherpa Configurations
#--------------------------------------------------------------------------------------------------------------------
# Sherpa's Hadoop Version
SHERPA_HADOOP_VERSION=2.7.1
# Sherpa's Hive Version
SHERPA_HIVE_VERSION=1.2.1
SHERPA_COMMON_JAR_NAME=TzCtCommon-1.0-jar-with-dependencies.jar
SHERPA_MR_JAR_NAME=hadoop-mapreduce-client-core-${SHERPA_HADOOP_VERSION}.jar
SHERPA_HIVE_CLI_JAR_NAME=hive-cli-${SHERPA_HIVE_VERSION}.jar
SHERPA_HIVE_EXEC_JAR_NAME=hive-exec-${SHERPA_HIVE_VERSION}.jar
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


mkdir -p ${INSTALL_DIR}

echo "Deploying MR Client ..."
cp  ${SHERPA_MR_JAR_NAME}             ${INSTALL_DIR}/
cp  ${SHERPA_COMMON_JAR_NAME}         ${INSTALL_DIR}/
cp  ${SHERPA_PROPERTY_FILE}           "/opt/sherpa.properties"
echo "Done Deploying MR Client ..."


echo "Deploying Hive Client ..."
cp  ${SHERPA_HIVE_CLI_JAR_NAME}             ${INSTALL_DIR}/
cp  ${SHERPA_HIVE_EXEC_JAR_NAME}            ${INSTALL_DIR}/
cp  ${SHERPA_COMMON_JAR_NAME}               ${INSTALL_DIR}/
echo "Done Deploying Hive Client ..."
