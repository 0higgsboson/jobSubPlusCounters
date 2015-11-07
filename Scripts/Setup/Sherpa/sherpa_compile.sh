#!/bin/bash

# Assumptions
# 1. Use root account
# 2. Run source /etc/environment to initialize $X_HOME variables.
# 3. Copy ssh public key into github


source /etc/environment
source sherpa_configurations.sh


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
sudo apt-get -y install openjdk-7-jre
sudo apt-get -y install openjdk-7-jdk


# Its a fix to use java version 7 on GCloud machines, comment that out if you are already using java 7
print "Updating java alternatives"
update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/java-7-openjdk-amd64/bin/java" 5000
update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/java-7-openjdk-amd64/bin/javac" 5000


# Installs Git if not installed already
print "Checking git install..."
git >> /dev/null
if [ "$?" -ne 0 ]; then
	apt-get -y install git
fi

# Installs Maven if not installed already
print "Checking maven install.."
mvn >> /dev/null
if [ "$?" -ne 0 ]; then
	apt-get -y install maven
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



##########################################################   Compiling Sherpa Project    ####################################################################
printHeader "Compiling Sherpa Project"

cd $sherpa_src_dir/jobSubPlusCounters
mvn clean install -DskipTests



##########################################################   Compiling Hive Client    ####################################################################
printHeader "Compile Hive Client"

cd $hive_client_src_dir/hiveClientSherpa
mvn clean install -pl ql,cli  -Phadoop-2  -DskipTests




##########################################################   Compiling Hadoop 2.6.0   ####################################################################
printHeader "Compiling Hadoop ..."

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



##########################################################   Compiling MR Client    ####################################################################
printHeader "Compiling MR Client"


cd ${mr_client_src_dir}/mrClient
mvn clean install -Pdist -DskipTests
