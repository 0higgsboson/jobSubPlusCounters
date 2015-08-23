#!/bin/bash

HADOOP_DIR=/opt/cloudera/parcels/CDH-5.4.4-1.cdh5.4.4.p0.4/lib/hadoop/
SPARK_DIR=/opt/cloudera/parcels/CDH-5.4.4-1.cdh5.4.4.p0.4/lib/spark/
HIVE_DIR=/opt/cloudera/parcels/CDH-5.4.4-1.cdh5.4.4.p0.4/lib/hive/
export JAVA_HOME="/usr/lib/jvm/java-7-oracle-cloudera/"

# Fix 1: Define Java_Home
# URL: https://github.com/intel-hadoop/HiBench/issues/93
# Error: INPUT_HDFS: unbound variable  appears if JAVA_HOME or Hadoop setting is not defined correctly 
# Checks Java_Home variable, assuming Java_Home will be already defined, exit script if not defined
if [ -z ${JAVA_HOME} ]; then
	echo "Please set JAVA_HOME variable"
        exit
fi 

# Fix 2: Benchmark run scripts assume libraries/jars to be present under Hadoop_Home/share/hadoop/mapreduce2/ 
# URL: same as that of Fix 1
# this dir does not exist by default
# Creating directory and coping required jars
echo "mkdir -p ${HADOOP_DIR}/share/hadoop/mapreduce2/"
mkdir -p ${HADOOP_DIR}/share/hadoop/mapreduce2/
cp ${HADOOP_DIR}/../../jars/*.jar ${HADOOP_DIR}/share/hadoop/mapreduce2/


# Fix 3: Spark hive SQL test requires hive configuration files to be copied into spark home dir
# https://issues.apache.org/jira/browse/HIVE-9198
# http://stackoverflow.com/questions/30343932/run-spark-sql-on-chd5-4-1-noclassdeffounderror
echo "Copying hive config files into spark home"
cp "${HIVE_DIR}"/conf/hive-site.xml  "${SPARK_DIR}"/conf/
echo "CLASSPATH=\"\$CLASSPATH:/opt/cloudera/parcels/CDH-5.4.4-1.cdh5.4.4.p0.4/lib/hive/lib/*\"" >> "${SPARK_DIR}"/bin/compute-classpath.sh


# Fix 4: HiBench.NutchData ERROR: number of words should be greater than 0
# https://github.com/intel-hadoop/HiBench/issues/36
echo "apt-get install wamerican"
apt-get install wamerican


# Fix 5: Import Error: No module named numpy
# Make sure numPy is Installed on all the nodes
# sudo aptitude install python-numpy


# Fix 6: Some of the tests fail to run due to hive table already defined
# Added hive drop table statements in HiBench run-all.sh script
# Copying modified script 
echo "cp run-all.sh /HiBenchTest/HiBench/bin/run-all.sh"
cp run-all.sh ~/HiBenchTest/HiBench/bin/run-all.sh


# Running the benchmark tests..
~/HiBenchTest/HiBench/bin/run-all.sh


# Finished benchmark tests
echo "Finished running benchmark tests"

