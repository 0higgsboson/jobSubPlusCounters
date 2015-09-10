#!/bin/bash

CDH_VERSION=CDH-5.4.5-1.cdh5.4.5.p0.7

mkdir SherpaHiveTest
cd    SherpaHiveTest

#apt-get install maven

update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/java-7-oracle-cloudera/bin/java" 50000
update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/java-7-oracle-cloudera/bin/javac" 50000


wget http://www.eu.apache.org/dist/hive/hive-1.1.1/apache-hive-1.1.1-bin.tar.gz
tar -xzvf apache-hive-1.1.1-bin.tar.gz

git clone https://github.com/0higgsboson/jobSubPlusCounters.git
cd jobSubPlusCounters/
mvn clean install -DskipTests
cd ..


git clone https://github.com/akhtar-m-din/Hive-Client.git
cd Hive-Client
mvn clean install -pl ql,cli  -Phadoop-2  -DskipTests
cd ..



cp Hive-Client/cli/target/hive-cli-1.1.0.jar apache-hive-1.1.1-bin/lib/hive-cli-1.1.1.jar
cp Hive-Client/ql/target/hive-exec-1.1.0.jar apache-hive-1.1.1-bin/lib/hive-exec-1.1.1.jar
cp jobSubPlusCounters/tunecore/target/tunecore-1.0-jar-with-dependencies.jar  apache-hive-1.1.1-bin/lib/tunecore-1.0-SNAPSHOT-jar-with-dependencies.jar


echo "drop table if exists docs_large;CREATE TABLE docs_large (line STRING);LOAD DATA LOCAL INPATH '/root/TestsData/large' OVERWRITE INTO TABLE docs_large;drop table if exists wc_large;CREATE TABLE wc_large AS SELECT word, count(1) AS count FROM (SELECT explode(split(line, '\s')) AS word FROM docs_large) w GROUP BY word ORDER BY word;" >> query.hql
./apache-hive-1.1.1-bin/bin/hive -f query.hql




export HADOOP_HOME=/opt/cloudera/parcels/${CDH_VERSION}/lib/hadoop/
export HBASE_HOME=/opt/cloudera/parcels/${CDH_VERSION}/lib/hadoop/


export HADOOP_HOME=/opt/cloudera/parcels/CDH-5.4.5-1.cdh5.4.5.p0.7/lib/hadoop/
export HBASE_HOME=/opt/cloudera/parcels/CDH-5.4.5-1.cdh5.4.5.p0.7/lib/hbase/
export JAVA_HOME=/usr/lib/jvm/java-7-oracle-cloudera/


cp /opt/cloudera/parcels/CDH-5.4.5-1.cdh5.4.5.p0.7/lib/hadoop/etc/hadoop/hadoop-env.sh  apache-hive-1.1.1-bin/conf/
cp /opt/cloudera/parcels/CDH-5.4.5-1.cdh5.4.5.p0.7/lib/hadoop/etc/hadoop/hdfs-site.xml  apache-hive-1.1.1-bin/conf/
cp /opt/cloudera/parcels/CDH-5.4.5-1.cdh5.4.5.p0.7/lib/hadoop/etc/hadoop/mapred-site.xml  apache-hive-1.1.1-bin/conf/
cp /opt/cloudera/parcels/CDH-5.4.5-1.cdh5.4.5.p0.7/lib/hadoop/etc/hadoop/yarn-site.xml  apache-hive-1.1.1-bin/conf/
cp /opt/cloudera/parcels/CDH-5.4.5-1.cdh5.4.5.p0.7/lib/hbase/conf/hbase-site.xml apache-hive-1.1.1-bin/conf/








#cp /root/jars/Sherpa/hive-cli-*.jar  /opt/cloudera/parcels/${CDH_VERSION}/jars/hive-cli-1.1.0-cdh5.4.5.jar
#cp /root/jars/Sherpa/hive-exec-*.jar    /opt/cloudera/parcels/${CDH_VERSION}/jars/hive-exec-1.1.0-cdh5.4.5.jar
