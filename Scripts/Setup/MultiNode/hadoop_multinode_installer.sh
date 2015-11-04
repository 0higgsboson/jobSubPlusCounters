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
pdsh -w ^${hosts_file} "mkdir -p $hadoop_dir"
pdsh -w ^${hosts_file} "mkdir -p $scripts_dir"


read -p "Do you want to clean up existing Hadoop data ( ${yarn_data_dir} ) [Y/n]? " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    pdsh -w ^${hosts_file}   "rm -r ${yarn_data_dir}"
fi

# Creates data dir's
print "Creating Data Dir's"
pdsh -w ^${hosts_file}   "mkdir -p ${yarn_data_dir}"






# Installs Hadoop
#----------------------------------

printHeader "Installing Hadoop"
print "Downloading Hadoop ${HADOOP_VERSION} ..."

cd $hadoop_dir
wget https://archive.apache.org/dist/hadoop/core/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
tar -xzvf hadoop-${HADOOP_VERSION}.tar.gz
cd hadoop-${HADOOP_VERSION}

print "Setting up configuration files ..."
rm etc/hadoop/core-site.xml
echo "<configuration>
       <property>
              <name>fs.defaultFS</name>
              <value>hdfs://${master}:9000</value>
          </property>
      </configuration>
"  >> etc/hadoop/core-site.xml


rm etc/hadoop/hdfs-site.xml
echo "<configuration>
    <property>
         <name>dfs.replication</name>
         <value>2</value>
     </property>
      <property>
          <name>dfs.permissions</name>
          <value>false</value>
       </property>

      <property>
          <name>dfs.webhdfs.enabled</name>
          <value>true</value>
      </property>
       <property>
         <name>dfs.namenode.name.dir</name>
         <value>file:${yarn_data_dir}/data/hdfs/nn</value>
       </property>
       <property>
         <name>fs.checkpoint.dir</name>
         <value>file:${yarn_data_dir}/data/hdfs/snn</value>
       </property>
       <property>
         <name>fs.checkpoint.edits.dir</name>
         <value>file:${yarn_data_dir}/data/hdfs/snn</value>
       </property>
       <property>
         <name>dfs.datanode.data.dir</name>
         <value>file:${yarn_data_dir}/data/hdfs/dn</value>
       </property>
       </configuration>
" >> etc/hadoop/hdfs-site.xml


echo "<configuration>
      <property>
              <name>mapreduce.framework.name</name>
              <value>yarn</value>
          </property>

      <property>
          <name>mapreduce.jobhistory.webapp.address</name>
          <value>${master}:19888</value>
        </property>
        <property>
          <name>mapreduce.jobhistory.webapp.https.address</name>
          <value>${master}:19890</value>
        </property>
      </configuration>
" >> etc/hadoop/mapred-site.xml


rm etc/hadoop/yarn-site.xml
echo "<configuration>
      <property>
              <name>yarn.nodemanager.aux-services</name>
              <value>mapreduce_shuffle</value>
          </property>

      <property>
      <name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>
      <value>org.apache.hadoop.mapred.ShuffleHandler</value>
      </property>

      <property>
        <description>Indicate to clients whether Timeline service is enabled or not.
        If enabled, the TimelineClient library used by end-users will post entities
        and events to the Timeline server.</description>
        <name>yarn.timeline-service.enabled</name>
        <value>true</value>
      </property>

      <property>
        <description>The setting that controls whether yarn system metrics is
        published on the timeline server or not by RM.</description>
        <name>yarn.resourcemanager.system-metrics-publisher.enabled</name>
        <value>true</value>
      </property>

      <property>
        <description>Indicate to clients whether to query generic application
        data from timeline history-service or not. If not enabled then application
        data is queried only from Resource Manager.</description>
        <name>yarn.timeline-service.generic-application-history.enabled</name>
        <value>true</value>
      </property>

      <property>
          <name>yarn.log-aggregation-enable</name>
          <value>true</value>
      </property>

      <property>
          <description>Where to aggregate logs to.</description>
          <name>yarn.nodemanager.remote-app-log-dir</name>
          <value>/tmp/logs</value>
      </property>

      <property>
          <name>yarn.log-aggregation.retain-seconds</name>
          <value>25920000</value>
      </property>

      <property>
          <name>yarn.log-aggregation.retain-check-interval-seconds</name>
          <value>36000</value>
      </property>

      <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>${master}:8031</value>
      </property>

      <property>
        <name>yarn.resourcemanager.scheduler.address</name>
        <value>${master}:8030</value>
       </property>

      <property>
        <name>yarn.resourcemanager.address</name>
        <value>${master}:8032</value>
      </property>


       <property>
          <name>yarn.resourcemanager.webapp.address</name>
          <value>${master}:8088</value>
        </property>
        <property>
          <name>yarn.resourcemanager.webapp.https.address</name>
          <value>${master}:8090</value>
        </property>

      </configuration>
" >> etc/hadoop/yarn-site.xml

sed -i -e '1iexport JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64\' etc/hadoop/hadoop-env.sh


echo "${master}" >> etc/hadoop/master
rm etc/hadoop/slaves
cp ${hosts_file} etc/hadoop/slaves


# Copies Hadoop Files to all hosts
print "Copying Hadoop Files to All Hosts ..."
pdsh -w ^${hosts_file} "mkdir -p ${hadoop_dir}/hadoop-${HADOOP_VERSION}"
pdcp -r -w ^${hosts_file} -x ${master} ${hadoop_dir}/hadoop-${HADOOP_VERSION}/ ${hadoop_dir}/hadoop-${HADOOP_VERSION}/



# Required to run hadoop commands
export PATH=$PATH:${hadoop_dir}/hadoop-${HADOOP_VERSION}/bin/

print "Formatting Namenode ..."
hadoop namenode -format


print "Creating Start/Stop Scripts ..."
rm ${scripts_dir}/hadoop_start.sh
touch ${scripts_dir}/hadoop_start.sh
echo "${hadoop_dir}/hadoop-${HADOOP_VERSION}/sbin/start-dfs.sh"                                 >> ${scripts_dir}/hadoop_start.sh
echo "${hadoop_dir}/hadoop-${HADOOP_VERSION}/sbin/start-yarn.sh"                                >> ${scripts_dir}/hadoop_start.sh
echo "${hadoop_dir}/hadoop-${HADOOP_VERSION}/sbin/mr-jobhistory-daemon.sh start historyserver"  >> ${scripts_dir}/hadoop_start.sh
echo "hadoop dfsadmin -safemode leave"                                              >> ${scripts_dir}/hadoop_start.sh
chmod +x ${scripts_dir}/hadoop_start.sh

rm ${scripts_dir}/hadoop_stop.sh
touch ${scripts_dir}/hadoop_stop.sh
echo "${hadoop_dir}/hadoop-${HADOOP_VERSION}/sbin/mr-jobhistory-daemon.sh stop historyserver"  >> ${scripts_dir}/hadoop_stop.sh
echo "${hadoop_dir}/hadoop-${HADOOP_VERSION}/sbin/stop-yarn.sh"                                >> ${scripts_dir}/hadoop_stop.sh
echo "${hadoop_dir}/hadoop-${HADOOP_VERSION}/sbin/stop-dfs.sh"                                 >> ${scripts_dir}/hadoop_stop.sh
chmod +x ${scripts_dir}/hadoop_stop.sh

print "Starting Hadoop Services ..."
${scripts_dir}/hadoop_start.sh



# defines HADOOP_HOME
defineEnvironmentVar "HADOOP_HOME" "${hadoop_dir}/hadoop-${HADOOP_VERSION}"

# adds Hadoop bin to Path variable
addToPath "${hadoop_dir}/hadoop-${HADOOP_VERSION}/bin"


jps
print "All Services Installed ..."