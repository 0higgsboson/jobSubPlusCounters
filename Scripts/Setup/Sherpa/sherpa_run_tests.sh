#!/bin/bash

# Assumptions
# 1. Use root account
# 2. Run source /etc/environment to initialize $X_HOME variables.
# 3. Copy ssh public key into github


source /etc/environment
source sherpa_configurations.sh



##########################################################   Running Hive Client Test    ####################################################################
printHeader "Running Hive Client Test"

cd $hive_client_src_dir/hiveClientSherpa


# create the config file to be used later in Sherpa managed testing
sudo touch /opt/sherpa.properties
sudo chmod 777 /opt/sherpa.properties
cat /dev/null > /opt/sherpa.properties
sudo printf "mapreduce.max.split.size=3000000\n" >> /opt/sherpa.properties
sudo printf "mapreduce.job.reduces=1\n" >> /opt/sherpa.properties

# Creates a temporary dir
cd ..
mkdir SherpaHiveTest
cd SherpaHiveTest

# Creates a sample workload
print "Creating sample workload ..."
hdfs dfs -mkdir /data
hdfs dfs -copyFromLocal $sherpa_src_dir/jobSubPlusCounters/core/src/main/java/com/sherpa/core/dao/WorkloadCountersPhoenixDAO.java /data/large
cat /dev/null > query.hql
echo "drop table if exists docs_large;CREATE TABLE docs_large (line STRING);LOAD DATA LOCAL INPATH '/root/TestsData/large' OVERWRITE INTO TABLE docs_large;drop table if exists wc_large;CREATE TABLE wc_large AS SELECT word, count(1) AS count FROM (SELECT explode(split(line, '\s')) AS word FROM docs_large) w GROUP BY word ORDER BY word;" >> query.hql


mkdir /root/TestsData/
hdfs dfs -copyToLocal /data/large /root/TestsData/


# Runs the test
print "Running test ..."
${hive_home}/bin/hive -f query.hql   -hiveconf PSManaged=true
cd ..

echo "Done Testing ..."





##########################################################   Running MR Client Test    ####################################################################
printHeader "Running MR Client Test"

cd ${mr_client_src_dir}/mrClient

print "Running test ..."
rm /opt/sherpa.properties
echo "
mapreduce.job.reduces=4
threshold=100
 " >> /opt/sherpa.properties

hdfs dfs -mkdir /input
hdfs dfs -copyFromLocal ${sherpa_src_dir}/jobSubPlusCounters/core/src/main/java/com/sherpa/core/dao/WorkloadCountersPhoenixDAO.java /input/

#yarn jar ${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar pi 10 100

hdfs dfs -rm -r /mrTestOutputBySherpa
yarn jar ${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar wordcount -D PSManaged=true /input/ /mrTestOutputBySherpa

