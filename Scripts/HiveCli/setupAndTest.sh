#!/bin/bash

#  To run that script
#  1. Define CDH Version
#  2. Change JAVA_HOME path if needed
#  3. Assumption is Wordcount large data is placed at HDFS: /data/large

#  You will be asked to enter user and password for Sherpa Performance Project, so keep watching



# Defines Cloudera's CDH Version
CDH_VERSION=CDH-5.4.5-1.cdh5.4.5.p0.7

export HADOOP_HOME=/opt/cloudera/parcels/${CDH_VERSION}/lib/hadoop/
export HBASE_HOME=/opt/cloudera/parcels/${CDH_VERSION}/lib/hbase/


# Change as per your system's settings, java version be should >=  1.7
export JAVA_HOME=/usr/lib/jvm/java-7-oracle-cloudera/

# Creates a temporary dir
mkdir SherpaHiveTest
cd    SherpaHiveTest


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


# Its a fix to use java vesion 7 on GCloud machines, comment that out if you are already using java 7
update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/java-7-oracle-cloudera/bin/java" 50000
update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/java-7-oracle-cloudera/bin/javac" 50000


# Sets up Sherpa Performance Project
echo "Setting up Sherpa Performance Project"
git clone https://github.com/0higgsboson/jobSubPlusCounters.git
cd jobSubPlusCounters/
mvn clean install -DskipTests
cd ..


# Downloads Apache Hive's Distribution 1.1.1
echo "Downloading Apache Hive ..."
wget http://www.eu.apache.org/dist/hive/hive-1.1.1/apache-hive-1.1.1-bin.tar.gz
tar -xzvf apache-hive-1.1.1-bin.tar.gz


# Sets up custom Hive Code
echo "Setting up custom Hive Code"
git clone https://github.com/akhtar-m-din/Hive-Client.git
cd Hive-Client
mvn clean install -pl ql,cli  -Phadoop-2  -DskipTests
cd ..


# Copies our jars into Hive's lib dir
echo "Copying jars into Hive's lib dir ..."
cp Hive-Client/cli/target/hive-cli-1.1.0.jar apache-hive-1.1.1-bin/lib/hive-cli-1.1.1.jar
cp Hive-Client/ql/target/hive-exec-1.1.0.jar apache-hive-1.1.1-bin/lib/hive-exec-1.1.1.jar
cp jobSubPlusCounters/tunecore/target/tunecore-1.0-jar-with-dependencies.jar  apache-hive-1.1.1-bin/lib/tunecore-1.0-SNAPSHOT-jar-with-dependencies.jar


# Creates a sample workload
echo "Creating a sample workload ..."
echo "drop table if exists docs_large;CREATE TABLE docs_large (line STRING);LOAD DATA LOCAL INPATH '/root/TestsData/large' OVERWRITE INTO TABLE docs_large;drop table if exists wc_large;CREATE TABLE wc_large AS SELECT word, count(1) AS count FROM (SELECT explode(split(line, '\s')) AS word FROM docs_large) w GROUP BY word ORDER BY word;" >> query.hql


# Copies data from HDFS, Assumption is data is placed at on HDFS /data/large
echo "Copying data from HDFS to local ..."
mkdir /root/TestsData/
hdfs dfs -copyToLocal /data/large /root/TestsData/


# Runs the test
echo "Starting sample workload ..."
./apache-hive-1.1.1-bin/bin/hive -f query.hql


# To run with parameters file, use the following command
# Parameter file should be located at /root/sherpa.properties
#./apache-hive-1.1.1-bin/bin/hive  -f query.hql -hiveconf PSManaged=true

echo "Done Testing ..."
