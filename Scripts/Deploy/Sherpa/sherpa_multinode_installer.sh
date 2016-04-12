#!/bin/bash

#
# Installs MR & Hive Clients on all hosts specified in a hosts file
#

#set -e

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


if [[ "$AUTH_TYPE" = "ssh"  ]];
then
    echo "SSH based cloning ..."
    if [[ "$HADOOP_VERSION" = "2.7.1"  ]];
    then
        MR_REPO_URL=git@github.com:0higgsboson/hadoop2.7.git
    else
        MR_REPO_URL=git@github.com:0higgsboson/mrClient.git
    fi
    HIVE_REPO_URL=git@github.com:0higgsboson/hiveClientSherpa.git
    JOBSUBPLUS_REPO_URL=git@github.com:0higgsboson/jobSubPlusCounters.git
    TZCTCOMMON_REPO_URL=git@github.com:0higgsboson/TzCtCommon.git
    TENZING_REPO_URL=git@github.com:0higgsboson/Tenzing.git
    CLIENTAGENT_REPO_URL=git@github.com:0higgsboson/ClientAgent.git
else
   echo "User/Password based cloning ..."
   if [[ "$HADOOP_VERSION" = "2.7.1"  ]];
    then
        MR_REPO_URL=https://github.com/0higgsboson/hadoop2.7.git
    else
        MR_REPO_URL=https://github.com/0higgsboson/mrClient.git
    fi
    HIVE_REPO_URL=https://github.com/0higgsboson/hiveClientSherpa.git
    JOBSUBPLUS_REPO_URL=https://github.com/0higgsboson/jobSubPlusCounters.git
    TZCTCOMMON_REPO_URL=https://github.com/0higgsboson/TzCtCommon.git
    TENZING_REPO_URL=https://github.com/0higgsboson/Tenzing.git
    CLIENTAGENT_REPO_URL=https://github.com/0higgsboson/ClientAgent.git
fi

if [[ "$HADOOP_VERSION" = "2.7.1"  ]];
then
    MR_SRC_DIR=hadoop2.7
    ACTIVE_PROFILE=H2.7.1
else
    MR_SRC_DIR=mrClient
    ACTIVE_PROFILE=H2.6
fi


# Create Directory Structure
print "Creating dir structure ..."
mkdir -p $mr_client_src_dir
mkdir -p $hive_client_src_dir
mkdir -p $hadoop_src_dir
mkdir -p $sherpa_src_dir
mkdir -p $common_src_dir
mkdir -p $tenzing_src_dir
mkdir -p $clientagent_src_dir


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


print "Installing PDSH ..."
apt-get -y install pdsh
pdsh -w ^${hosts_list}   "apt-get -y install pdsh"

# Defines shell for pdsh to avoid connection refused exceptions
export PDSH_RCMD_TYPE=ssh
pdsh -w ^${hosts_file}    "export PDSH_RCMD_TYPE=ssh"

##########################################################   Cloning Repo's    ####################################################################

if [[ "$CLONE_REPOS" = "yes"  ]];
then
    printHeader "Cloning Repo's"

    # Cloning Sherpa Performance Project
    print "Cloning Sherpa Performance Project"
    cd $sherpa_src_dir
    git clone ${JOBSUBPLUS_REPO_URL}


    # Cloning TzCtCommon
    print "Cloning TzCtCommon Project"
    cd ${common_src_dir}
    git clone ${TZCTCOMMON_REPO_URL}


    # Cloning custom Hive Code
    print "Cloning custom Hive Project"
    cd $hive_client_src_dir
    git clone ${HIVE_REPO_URL}

    # Cloning custom MR Code
    print "Cloning custom MR Project"
    cd $mr_client_src_dir
    git clone ${MR_REPO_URL}


     # Cloning Tenzing Code
    print "Cloning Tenzing Project"
    cd ${tenzing_src_dir}
    git clone ${TENZING_REPO_URL}


     # Cloning CA Code
    print "Cloning Client Agent Project"
    cd ${clientagent_src_dir}
    git clone ${CLIENTAGENT_REPO_URL}

fi


#
#   Installing TzCtCommon
# ======================================================================================================================================

printHeader "Installing TzCtCommon Project"
cd ${common_src_dir}/TzCtCommon/
mvn clean install -DskipTests  -P${ACTIVE_PROFILE}


#
#   Packaging Tenzing
# ======================================================================================================================================

printHeader "Packaging Tenzing"
cd ${tenzing_src_dir}/Tenzing/
mvn clean package -DskipTests  -P${ACTIVE_PROFILE}



#
#   Packaging Client Agent
# ======================================================================================================================================

printHeader "Packaging Client Agent"
cd ${clientagent_src_dir}/ClientAgent/
mvn clean package -DskipTests  -P${ACTIVE_PROFILE}




#
#   Installing Hive Client
# ======================================================================================================================================

printHeader "Installing Hive Client"
cd $hive_client_src_dir/hiveClientSherpa
mvn clean package -pl ql,cli  -Phadoop-2  -DskipTests

# Copies custom jars into Hive's lib dir
print "Copying Jars ..."
pdcp -r -w ^${hosts_file}   "${hive_client_src_dir}/hiveClientSherpa/cli/target/hive-cli-1.2.1.jar" "${hive_home}/lib/hive-cli-1.2.1.jar"
pdcp -r -w ^${hosts_file}   "${hive_client_src_dir}/hiveClientSherpa/ql/target/hive-exec-1.2.1.jar" "${hive_home}/lib/hive-exec-1.2.1.jar"
pdcp -r -w ^${hosts_file}   "${common_src_dir}/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar" "${hive_home}/lib/TzCtCommon-1.0-jar-with-dependencies.jar"
pdcp -r -w ^${hosts_file}    "${CWD}/sherpa.properties"    "/opt/sherpa.properties"

# Fixes hive error
pdsh -w ^${hosts_file}   "rm ${hadoop_home}/share/hadoop/yarn/lib/jline-0.9.94.jar"
echo "Hive Client Deployed ..."




#
#   Installing MR Client
# ======================================================================================================================================

printHeader "Installing MR Client"
cd ${mr_client_src_dir}/${MR_SRC_DIR}
mvn clean package -Pdist -DskipTests


print "Copying Jars ..."
pdcp -r -w ^${hosts_file}   "${mr_client_src_dir}/${MR_SRC_DIR}/target/hadoop-mapreduce-client-core-${HADOOP_VERSION}.jar"  "${hadoop_home}/share/hadoop/mapreduce/hadoop-mapreduce-client-core-${HADOOP_VERSION}.jar"
pdcp -r -w ^${hosts_file}   "${common_src_dir}/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar" "${hadoop_home}/share/hadoop/mapreduce/lib/"
pdcp -r -w ^${hosts_file}   "${CWD}/sherpa.properties" "/opt/sherpa.properties"

echo "MR Client Deployed ..."
echo "!!! Restart Hadoop Services ..."


# Copying Tenzing & CA Jars into CWD
cp  ${tenzing_src_dir}/Tenzing/target/Tenzing-1.0-jar-with-dependencies.jar                ${CWD}/
cp  ${clientagent_src_dir}/ClientAgent/target/ClientAgent-1.0-jar-with-dependencies.jar    ${CWD}/
