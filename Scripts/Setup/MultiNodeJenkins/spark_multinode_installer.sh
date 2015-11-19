#!/bin/bash

# Assumptions
# 1. Use root account
# 2. First node of hosts file will be treated as master node
# 3. Public/Private keys should already be set up

if [ "$#" -ne 1 ]; then
    echo "Usage: hosts_file_path"
    exit
fi


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
pdsh -w ^${hosts_file} "mkdir -p $spark_dir"
pdsh -w ^${hosts_file} "mkdir -p $scripts_dir"




# Installs Spark
#----------------------------------
printHeader "Installing Spark ${SPARK_VERSION}"
cd $spark_dir

cp ${sherpa_repo_dir}/downloads/spark-${SPARK_VERSION}-bin-hadoop2.6.tgz ${spark_dir}/spark-${SPARK_VERSION}-bin-hadoop2.6.tgz

tar -xzvf spark-${SPARK_VERSION}-bin-hadoop2.6.tgz
cd spark-${SPARK_VERSION}-bin-hadoop2.6

print "Setting up Spark configuration files ..."
echo "
spark.master                     spark://${master}:7077
spark.eventLog.enabled           true
spark.eventLog.dir               hdfs://${master}:9000/sparkLogs
spark.history.fs.logDirectory    hdfs://${master}:9000/sparkLogs
" >> conf/spark-defaults.conf

cp conf/spark-env.sh.template conf/spark-env.sh
sed -i -e '1iexport JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64\' conf/spark-env.sh


cp ${hosts_file} conf/slaves

# Copies Spark Files to all hosts
print "Copying Spark Files to All Hosts ..."
pdsh -w ^${hosts_file} -x ${master} "mkdir -p ${spark_dir}/spark-${SPARK_VERSION}-bin-hadoop2.6"
pdcp -r -w ^${hosts_file} -x ${master} ${spark_dir}/spark-${SPARK_VERSION}-bin-hadoop2.6/ ${spark_dir}/spark-${SPARK_VERSION}-bin-hadoop2.6/




print "Creating Spark Start/Stop Scripts ..."
rm ${scripts_dir}/spark_start.sh
touch ${scripts_dir}/spark_start.sh
echo "${spark_dir}/spark-${SPARK_VERSION}-bin-hadoop2.6/sbin/start-master.sh"                                  >> ${scripts_dir}/spark_start.sh
echo "${spark_dir}/spark-${SPARK_VERSION}-bin-hadoop2.6/sbin/start-slaves.sh"                                  >> ${scripts_dir}/spark_start.sh
echo "${spark_dir}/spark-${SPARK_VERSION}-bin-hadoop2.6/sbin/start-history-server.sh"                          >> ${scripts_dir}/spark_start.sh
chmod +x ${scripts_dir}/spark_start.sh

rm ${scripts_dir}/spark_stop.sh
touch ${scripts_dir}/spark_stop.sh
echo "${spark_dir}/spark-${SPARK_VERSION}-bin-hadoop2.6/sbin/stop-all.sh"                                  >> ${scripts_dir}/spark_stop.sh
chmod +x ${scripts_dir}/spark_stop.sh


# Required to run hadoop commands
export PATH=$PATH:${hadoop_dir}/hadoop-${HADOOP_VERSION}/bin/

print "Creating spark log dir ..."
hdfs dfs -mkdir hdfs://${master}:9000/sparkLogs

print "Starting Spark ..."
${scripts_dir}/spark_start.sh



print "Setting up Path & Environment Variables ..."

# defines SPARK_HOME
defineEnvironmentVar "SPARK_HOME" "${spark_dir}/spark-${SPARK_VERSION}-bin-hadoop2.6/"

# adds Spark bin to Path variable
addToPath "${spark_dir}/spark-${SPARK_VERSION}-bin-hadoop2.6/bin/"


jps
print "All Services Installed ..."