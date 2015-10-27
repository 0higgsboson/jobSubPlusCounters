#!/bin/bash

# Assumptions
# 1. Use root account
#


###############################################  Configurations #######################################################

  # define following directories without ending slash /
installation_base_dir=/root/sherpa
hive_home=/root/cluster/hive/apache-hive-1.2.1-bin
hadoop_home=/root/cluster/hadoop/hadoop-2.6.0
scripts_home=/root/scripts

#######################################################################################################################


source /etc/environment


# Printing Functions
function print(){
  printf "\n"
  echo "$1"
  echo "================================"
}

function printHeader(){
  printf "\n\n"
  echo "**************************************** $1 ***********************************************"
}

mr_client_src_dir="${installation_base_dir}/mr_client_src"
hive_client_src_dir="${installation_base_dir}/hive_client_src"
hadoop_src_dir="${installation_base_dir}/hadoop_src"
sherpa_src_dir="${installation_base_dir}/jobSubPub_src"


# Create Directory Structure
print "Creating dir structure ..."
mkdir -p $mr_client_src_dir
mkdir -p $hive_client_src_dir
mkdir -p $hadoop_src_dir
mkdir -p $sherpa_src_dir

print "Updating ..."
sudo apt-get update


# Install Java
print "Installing Java ..."
sudo apt-get install openjdk-7-jre
sudo apt-get install openjdk-7-jdk


# Its a fix to use java version 7 on GCloud machines, comment that out if you are already using java 7
print "Updating java alternatives"
update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/java-7-openjdk-amd64/bin/java" 50000
update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/java-7-openjdk-amd64/bin/javac" 50000


# Installs Git if not installed already
print "Checking git install..."
git >> /dev/null
if [ "$?" -ne 0 ]; then
	apt-get install git
fi

# Installs Maven if not installed already
print "Checking maven install.."
mvn >> /dev/null
if [ "$?" -ne 0 ]; then
	apt-get install maven
fi

# Define Java Home
print "Defining Java Home ..."
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/



##########################################################   Cloning Repo's    ####################################################################
printHeader "Cloning Repo's"

# Cloning Sherpa Performance Project
print "Cloning Sherpa Performance Project"
cd $sherpa_src_dir
git clone https://github.com/0higgsboson/jobSubPlusCounters.git

# Cloning custom Hive Code
print "Cloning custom Hive Code"
cd $hive_client_src_dir
git clone https://github.com/0higgsboson/hiveClientSherpa.git

# Cloning custom MR Code
print "Cloning custom MR Code"
cd $mr_client_src_dir
git clone https://github.com/0higgsboson/mrClient.git

# Cloning Hadoop 2.6.0 Code
print "Cloning Hadoop 2.6.0 Code"
cd $hadoop_src_dir
wget https://archive.apache.org/dist/hadoop/core/hadoop-2.6.0/hadoop-2.6.0-src.tar.gz



##########################################################   Installing Sherpa Project    ####################################################################
printHeader "Installing Sherpa Project"

print "Compiling Sherpa Project"
cd $sherpa_src_dir/jobSubPlusCounters
mvn clean install -DskipTests



##########################################################   Installing & Testing Hive Client    ####################################################################
printHeader "Installing Hive Client"

print "Installing Hive Client"
cd $hive_client_src_dir/hiveClientSherpa
mvn clean install -pl ql,cli  -Phadoop-2  -DskipTests

# Copies custom jars into Hive's lib dir
print "Copying jars into Hive's lib dir ..."
cp cli/target/hive-cli-1.2.1.jar ${hive_home}/lib/hive-cli-1.2.1.jar
cp ql/target/hive-exec-1.2.1.jar ${hive_home}/lib/hive-exec-1.2.1.jar
cp $sherpa_src_dir/jobSubPlusCounters/tunecore/target/tunecore-1.0-jar-with-dependencies.jar  ${hive_home}/lib/tunecore-1.0-SNAPSHOT-jar-with-dependencies.jar

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





##########################################################   Compiling Hadoop 2.6.0   ####################################################################
printHeader "Compiling Hadoop ..."

print "Extracting Hadoop ..."
cd $hadoop_src_dir
tar -xzvf hadoop-2.6.0-src.tar.gz

print "Installing Hadoop Build Dependencies ..."
apt-get -y install maven build-essential autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev libfuse-dev

wget https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz
tar xvf protobuf-2.5.0.tar.gz
cd protobuf-2.5.0
./configure
make
sudo make install
sudo ldconfig
protoc --version


print "Compiling Hadoop ..."
cd hadoop-2.6.0-src
mvn clean install -Pdist -DskipTests



##########################################################   Installing & Testing MR Client    ####################################################################
printHeader "Installing MR Client"

print "Compiling MR Client"
cd ${mr_client_src_dir}/mrClient
mvn clean install -Pdist -DskipTests

print "Stopping Hadoop services ..."
${scripts_home}/hadoop_stop.sh

print "Copying Jars ..."
cp ${mr_client_src_dir}/mrClient/target/hadoop-mapreduce-client-core-2.6.0.jar ${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.6.0.jar
cp ${sherpa_src_dir}/jobSubPlusCounters/tunecore/target/tunecore-1.0-jar-with-dependencies.jar ${hadoop_home}/share/hadoop/mapreduce/lib/

print "Starting Hadoop services ..."
${scripts_home}/hadoop_start.sh


print "Running test ..."
rm /opt/sherpa.properties
echo "
mapreduce.job.reduces=4
threshold=100
 " >> /opt/sherpa.properties

hdfs dfs -mkdir /input
hdfs dfs -copyFromLocal ${sherpa_src_dir}/jobSubPlusCounters/core/src/main/java/com/sherpa/core/dao/WorkloadCountersPhoenixDAO.java /input/

yarn jar ${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar wordcount -D PSManaged=true /input/ /output
