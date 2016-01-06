#!/bin/bash

source /etc/environment
source sherpa_configurations.sh



##########################################################   Running Hive Client Test    ####################################################################
printHeader "Running Hive Client Test"

echo "Hive Dir: $hive_client_src_dir/hiveClientSherpa "
cd $hive_client_src_dir/hiveClientSherpa


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
echo "Running: ${hive_home}/bin/hive -f query.hql   -hiveconf PSManaged=false"
${hive_home}/bin/hive -f query.hql   -hiveconf PSManaged=true
cd ..

echo "Done Testing ..."



