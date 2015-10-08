#!/bin/bash

#  To run that script
#  1. Define CDH Version
#  2. Change JAVA_HOME path if needed
#  3. Assumption is Wordcount large data is placed at HDFS: /data/large

#  You will be asked to enter user and password for Sherpa Performance Project, so keep watching


# Defines Cloudera's CDH Version
CDH_VERSION=CDH-5.4.5-1.cdh5.4.5.p0.7
CDH_END_VER=cdh5.4.5
MR_CLIENT_VER="2.6.0"

export HADOOP_HOME=/opt/cloudera/parcels/${CDH_VERSION}/lib/hadoop/
export HBASE_HOME=/opt/cloudera/parcels/${CDH_VERSION}/lib/hbase/

# Change as per your system's settings, java version be should >=  1.7
export JAVA_HOME=/usr/lib/jvm/java-7-oracle-cloudera/


# Installs Maven if not installed already
echo "Checking maven install.."
mvn >> /dev/null
if [ "$?" -ne 0 ]; then
	apt-get install maven
fi


# Installs Git if not installed already
echo "Checking git install.."
git >> /dev/null
if [ "$?" -ne 0 ]; then
	apt-get install git
fi


# It's a fix to use java vesion 7 on GCloud machines, comment that out if you are already using java 7
update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/java-7-oracle-cloudera/bin/java" 50000
update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/java-7-oracle-cloudera/bin/javac" 50000


# Cloning Sherpa Performance Project
echo "Cloning Sherpa Performance Project"
git clone https://github.com/0higgsboson/jobSubPlusCounters.git


# Cloning custom Sherpa MapReduce Client Code
echo "Cloning custom MR Code"
git clone https://github.com/0higgsboson/mrClient


# Compiling Sherpa Project
echo "Compiling Sherpa Performance Project"
cd jobSubPlusCounters/
mvn clean install -DskipTests
cd ..

# Compiling custom MR Code
echo "Compiling custom MR Code"
cd mrClient
mvn clean install -Pdist -DskipTests
cd ..

# Move Sherpa's MR client and overwrite the CDH client
sudo mv  /opt/cloudera/parcels/${CDH_VERSION}/jars/hadoop-mapreduce-client-core-${MR_CLIENT_VER}-${CDH_END_VER}.jar /opt/cloudera/parcels/${CDH_VERSION}/jars/hadoop-mapreduce-client-core-${MR_CLIENT_VER}-${CDH_END_VER}.org 

cd mrClient
sudo cp target/hadoop-mapreduce-client-core-${MR_CLIENT_VER}.jar /opt/cloudera/parcels/${CDH_VERSION}/jars/hadoop-mapreduce-client-core-${MR_CLIENT_VER}-${CDH_END_VER}.jar
cd ..

# Creates a sample workload
echo "Creating a sample workload ..."
#echo "drop table if exists docs_large;CREATE TABLE docs_large (line STRING);LOAD DATA LOCAL INPATH #'/root/TestsData/large' OVERWRITE INTO TABLE docs_large;drop table if exists wc_large;CREATE TABLE wc_large AS #SELECT word, count(1) AS count FROM (SELECT explode(split(line, '\s')) AS word FROM docs_large) w GROUP BY word #ORDER BY word;" >> query.hql


# Generating a parameter configuration file
sudo touch /opt/sherpa.properties
sudo chmod 777 /opt/sherpa.properties
cat /dev/null > /opt/sherpa.properties
sudo printf "mapreduce.max.split.size=300000000\n" >> /opt/sherpa.properties
sudo printf "mapreduce.job.reduces=12\n" >> /opt/sherpa.properties


# Copies data from HDFS, Assumption is that data is placed on HDFS /data/large location
#echo "Copying data from HDFS to local ..."
#mkdir /root/TestsData/
#hdfs dfs -copyToLocal /data/large /root/TestsData/
 

# Runs the test
echo "Starting sample workload test..."
cd jobSubPlusCounters

echo "Regular/large file test..."
yarn jar custominputformat/target/custominputformat-1.0.jar com.sherpa.custominputformat.WordCountDriver   /data/large /output/large

#if [ "$?" -ne 0 ]; then
#  echo "FAILED: PS MR test with large data input"
#fi

# Run test without manager first
echo "Small files test without Sherpa manager..."
yarn jar custominputformat/target/custominputformat-1.0.jar com.sherpa.custominputformat.WordCountDriver /data/small /output/small

# Run test with manager
echo "Small files test WITH Sherpa manager..."
yarn jar custominputformat/target/custominputformat-1.0.jar com.sherpa.custominputformat.CombineInputFormatWordCountDriver /data/small /output/small PSManaged=true

echo "Done Testing ..."
