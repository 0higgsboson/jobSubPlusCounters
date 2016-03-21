#!/bin/bash

# Assumptions
# 1. For un-attended installation, copy ssh public key into github

if [ "$#" -ne 1 ]; then
    echo "Usage: hosts_file_path"
    echo "For single node installation use sherpa_installer.sh"
    exit
fi

hosts_file=$1


# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`
echo "Current Working Dir: ${CWD}"

# load configurations & utils functions
source "${CWD}"/sherpa_installer_configurations.sh
source "${CWD}"/utils.sh

source /etc/environment


# Create Directory Structure
print "Creating dir structure ..."
mkdir -p $mr_client_src_dir
mkdir -p $hive_client_src_dir
mkdir -p $hadoop_src_dir
mkdir -p $sherpa_src_dir
mkdir -p $common_src_dir


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


#
export PDSH_RCMD_TYPE=ssh
pdsh -w ^${hosts_file}    "export PDSH_RCMD_TYPE=ssh"

##########################################################   Cloning Repo's    ####################################################################
printHeader "Cloning Repo's"

# Cloning Sherpa Performance Project
print "Cloning Sherpa Performance Project"
cd $sherpa_src_dir
git clone https://github.com/0higgsboson/jobSubPlusCounters.git


# Cloning TzCtCommon
print "Cloning TzCtCommon Project"
cd ${common_src_dir}
git clone https://github.com/0higgsboson/TzCtCommon.git


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

print "Compiling TzCtCommon Project"
cd ${common_src_dir}/TzCtCommon/
mvn clean install -DskipTests


##########################################################   Installing & Testing Hive Client    ####################################################################
printHeader "Installing Hive Client"

print "Installing Hive Client"
cd $hive_client_src_dir/hiveClientSherpa
mvn clean install -pl ql,cli  -Phadoop-2  -DskipTests

# Copies custom jars into Hive's lib dir
print "Copying jars into Hive's lib dir ..."
pdcp -r -w ^${hosts_file}   "${hive_client_src_dir}/hiveClientSherpa/cli/target/hive-cli-1.2.1.jar" "${hive_home}/lib/hive-cli-1.2.1.jar"
pdcp -r -w ^${hosts_file}   "${hive_client_src_dir}/hiveClientSherpa/ql/target/hive-exec-1.2.1.jar" "${hive_home}/lib/hive-exec-1.2.1.jar"
pdcp -r -w ^${hosts_file}   "${sherpa_src_dir}/jobSubPlusCounters/tunecore/target/tunecore-1.0-jar-with-dependencies.jar"  "${hive_home}/lib/tunecore-1.0-SNAPSHOT-jar-with-dependencies.jar"
pdcp -r -w ^${hosts_file}   "${common_src_dir}/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar" "${hive_home}/lib/TzCtCommon-1.0-jar-with-dependencies.jar"

# Fixes hive error
pdsh -w ^${hosts_file}   "rm ${hadoop_dir}/hadoop-${HADOOP_VERSION}/share/hadoop/yarn/lib/jline-0.9.94.jar"



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
cd ../hadoop-2.6.0-src
mvn clean install -Pdist -DskipTests



##########################################################   Installing & Testing MR Client    ####################################################################
printHeader "Installing MR Client"

print "Compiling MR Client"
cd ${mr_client_src_dir}/mrClient
mvn clean install -Pdist -DskipTests

print "Stopping Hadoop services ..."
${scripts_home}/hadoop_stop.sh

print "Copying Jars ..."
pdcp -r -w ^${hosts_file}   "${mr_client_src_dir}/mrClient/target/hadoop-mapreduce-client-core-2.6.0.jar"  "${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.6.0.jar"
pdcp -r -w ^${hosts_file}   "${sherpa_src_dir}/jobSubPlusCounters/tunecore/target/tunecore-1.0-jar-with-dependencies.jar" "${hadoop_home}/share/hadoop/mapreduce/lib/"
pdcp -r -w ^${hosts_file}   "${common_src_dir}/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar" "${hadoop_home}/share/hadoop/mapreduce/lib/"


print "Starting Hadoop services ..."
${scripts_home}/hadoop_start.sh


printHeader "Installing Tenzing"
"${CWD}"/tenzing_installer.sh


printHeader "Installing Client Agent"
"${CWD}"/client_agent_installer.sh