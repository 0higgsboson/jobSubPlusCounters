#!/bin/bash
CDH_VERSION=CDH-5.4.5-1.cdh5.4.5.p0.7
cp /root/jars/Sherpa/hive-cli-*.jar  /opt/cloudera/parcels/${CDH_VERSION}/jars/hive-cli-1.1.0-cdh5.4.5.jar
cp /root/jars/Sherpa/hive-exec-*.jar    /opt/cloudera/parcels/${CDH_VERSION}/jars/hive-exec-1.1.0-cdh5.4.5.jar
