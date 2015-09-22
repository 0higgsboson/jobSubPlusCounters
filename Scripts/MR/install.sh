#!/bin/bash
CDH_VERSION=CDH-5.4.5-1.cdh5.4.5.p0.7
MR_CLIENT_PATH=/home/ubuntu/MR
MR_BACKUP_PATH=/home/ubuntu/MR_Backup

echo "Copying original jar at ${MR_BACKUP_PATH} ..."
cp /opt/cloudera/parcels/${CDH_VERSION}/jars/hadoop-mapreduce-client-core-2.6.0-cdh5.4.5.jar  ${MR_BACKUP_PATH}/hadoop-mapreduce-client-core-2.6.0-cdh5.4.5.jar


echo "Copying sherpa jar ..."
sudo cp ${MR_CLIENT_PATH}/target/hadoop-mapreduce-client-core-2.6.0.jar /opt/cloudera/parcels/${CDH_VERSION}/jars/hadoop-mapreduce-client-core-2.6.0-cdh5.4.5.jar

