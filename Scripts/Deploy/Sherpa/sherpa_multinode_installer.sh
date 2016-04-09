#!/bin/bash

# Assumptions
# 1. For un-attended installation, copy ssh public key into github

if [ "$#" -ne 1 ]; then
    echo "Usage: hosts_file_path"
    exit
fi

hosts_file=`readlink -f $1`

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source "${CWD}"/configurations.sh
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
sudo apt-get -y install  openjdk-7-jre
sudo apt-get -y install  openjdk-7-jdk


# Its a fix to use java version 7 on GCloud machines, comment that out if you are already using java 7
print "Updating java alternatives"
update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/java-7-openjdk-amd64/bin/java" 50000
update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/java-7-openjdk-amd64/bin/javac" 50000


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


#

print "Installing PDSH ..."
apt-get -y install pdsh
pdsh -w ^${hosts_list}   "apt-get -y install pdsh"

export PDSH_RCMD_TYPE=ssh
pdsh -w ^${hosts_file}    "export PDSH_RCMD_TYPE=ssh"

##########################################################   Cloning Repo's    ####################################################################

if [[ "$CLONE_REPOS" = "yes"  ]];
then
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
    git clone ${MR_REPO_URL}

fi


##########################################################   Installing Sherpa Project    ####################################################################
printHeader "Installing Sherpa Project"

#print "Compiling Sherpa Project"
#cd $sherpa_src_dir/jobSubPlusCounters
#mvn clean install -DskipTests -P${ACTIVE_PROFILE}

print "Compiling TzCtCommon Project"
cd ${common_src_dir}/TzCtCommon/
mvn clean install -DskipTests  -P${ACTIVE_PROFILE}


##########################################################   Installing & Testing Hive Client    ####################################################################
printHeader "Installing Hive Client"

print "Installing Hive Client"
cd $hive_client_src_dir/hiveClientSherpa
# Using install instead of package on Dev env may lead to cyclic dependency issue, always use package unless there is some special reason
mvn clean package -pl ql,cli  -Phadoop-2  -DskipTests

# Copies custom jars into Hive's lib dir
print "Copying jars into Hive's lib dir ..."
pdcp -r -w ^${hosts_file}   "${hive_client_src_dir}/hiveClientSherpa/cli/target/hive-cli-1.2.1.jar" "${hive_home}/lib/hive-cli-1.2.1.jar"
pdcp -r -w ^${hosts_file}   "${hive_client_src_dir}/hiveClientSherpa/ql/target/hive-exec-1.2.1.jar" "${hive_home}/lib/hive-exec-1.2.1.jar"
#pdcp -r -w ^${hosts_file}   "${sherpa_src_dir}/jobSubPlusCounters/tunecore/target/tunecore-1.0-jar-with-dependencies.jar"  "${hive_home}/lib/tunecore-1.0-SNAPSHOT-jar-with-dependencies.jar"
pdcp -r -w ^${hosts_file}   "${common_src_dir}/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar" "${hive_home}/lib/TzCtCommon-1.0-jar-with-dependencies.jar"
pdcp -r -w ^${hosts_file}    "${CWD}/sherpa.properties"    "/opt/sherpa.properties"


# Fixes hive error
pdsh -w ^${hosts_file}   "rm ${hadoop_home}/share/hadoop/yarn/lib/jline-0.9.94.jar"



##########################################################   Installing & Testing MR Client    ####################################################################
printHeader "Installing MR Client"

print "Compiling MR Client"
cd ${mr_client_src_dir}/${SRC_DIR}
# Using install instead of package on Dev env may lead to cyclic dependency issue, always use package unless there is some special reason
mvn clean package -Pdist -DskipTests


print "Copying Jars ..."
pdcp -r -w ^${hosts_file}   "${mr_client_src_dir}/${SRC_DIR}/target/hadoop-mapreduce-client-core-${HADOOP_VERSION}.jar"  "${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-client-core-${HADOOP_VERSION}.jar"
#pdcp -r -w ^${hosts_file}   "${sherpa_src_dir}/jobSubPlusCounters/tunecore/target/tunecore-1.0-jar-with-dependencies.jar" "${hadoop_home}/share/hadoop/mapreduce/lib/"
pdcp -r -w ^${hosts_file}   "${common_src_dir}/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar" "${hadoop_home}/share/hadoop/mapreduce/lib/"

pdcp -r -w ^${hosts_file}   "${CWD}/sherpa.properties" "/opt/sherpa.properties"


echo "Done with installation ..."