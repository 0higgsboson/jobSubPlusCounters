#!/bin/bash

# Assumptions
# 1. Use root account
# 2. First node of hosts file will be treated as master node
# 3. Public/Private keys should already be set up

if [ "$#" -ne 1 ]; then
    echo "Usage: hosts_file_path"
    exit
fi

set -e

# includes configurations
source configurations.sh

# includes utils functions
source utils.sh

# defines hosts_file and master variables, these two variables will be used throughout the script
setupMasterNode "$1"

# Setting up pdsh utility
installPdsh "${hosts_file}" "${master}"


# installs java, git and sets up JAVA_HOME environment variable on all hosts
installPreReqs "${hosts_file}"


print "Creating dir structure ..."
pdsh -w ^${hosts_file} "mkdir -p $hive_dir"
pdsh -w ^${hosts_file} "mkdir -p $scripts_dir"




# Installs Hive
#----------------------------------

printHeader "Installing Hive ${HIVE_VERSION}"
cd $hive_dir

print "Downloading Apache Hive ${HIVE_VERSION} ..."
wget http://www.eu.apache.org/dist/hive/stable/apache-hive-${HIVE_VERSION}-bin.tar.gz
tar -xzvf apache-hive-${HIVE_VERSION}-bin.tar.gz
cd apache-hive-${HIVE_VERSION}-bin

cp conf/hive-env.sh.template conf/hive-env.sh
#sed -i -e "1iexport HADOOP_HOME=${hadoop_dir}/hadoop-${HADOOP_VERSION}\" conf/hive-env.sh
echo "export HADOOP_HOME=${hadoop_dir}/hadoop-${HADOOP_VERSION}/" >> conf/hive-env.sh


# Copies Hive Files to all hosts
print "Copying Hive Files to All Hosts ..."
pdsh    -w ^${hosts_file}  -x ${master} "mkdir -p ${hive_dir}/apache-hive-${HIVE_VERSION}-bin"
pdcp -r -w ^${hosts_file}  -x ${master} ${hive_dir}/apache-hive-${HIVE_VERSION}-bin/ ${hive_dir}/apache-hive-${HIVE_VERSION}-bin/




# Hive Error Fix
# http://stackoverflow.com/questions/28997441/hive-startup-error-terminal-initialization-failed-falling-back-to-unsupporte
# https://cwiki.apache.org/confluence/display/Hive/Hive+on+Spark%3A+Getting+Started
rm ${hadoop_dir}/hadoop-${HADOOP_VERSION}/share/hadoop/yarn/lib/jline-0.9.94.jar


print "Setting up Path & Environment Variables ..."

# defines HIVE_HOME
defineEnvironmentVar "HIVE_HOME" "${hive_dir}/apache-hive-${HIVE_VERSION}-bin/"

# adds Hive bin to Path variable
addToPath "${hive_dir}/apache-hive-${HIVE_VERSION}-bin/bin/"


jps
print "All Services Installed ..."