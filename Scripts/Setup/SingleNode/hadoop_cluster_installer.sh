#!/bin/bash

# Assumptions
# 1. Use root account
# 2. Default host name is tenzing-red.  If different, update the script to reflect this before running it.
# 3. Run source /etc/environment right after running the hadoop cluster installer


###############################################  Configurations #######################################################
host_name=tenzing-red

  # define following directories without ending slash /
yarn_data_dir=/mnt/yarn
hbase_data_dir=/mnt/hbase
installation_base_dir=/root

#######################################################################################################################


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


hadoop_dir="${installation_base_dir}/cluster/hadoop/"
hbase_dir="${installation_base_dir}/cluster/hbase/"
phoenix_dir="${installation_base_dir}/cluster/phoenix/"
hive_dir="${installation_base_dir}/cluster/hive/"
spark_dir="${installation_base_dir}/cluster/spark/"
scripts_dir="${installation_base_dir}/scripts/"

# Create Directory Structure
print "Creating dir structure ..."
mkdir -p $hadoop_dir
mkdir -p $hbase_dir
mkdir -p $phoenix_dir
mkdir -p $hive_dir
mkdir -p $spark_dir
mkdir -p $scripts_dir

print "Updating ..."
sudo apt-get update


read -p "Do you want to clean up existing Hadoop ( ${yarn_data_dir} ) & Hbase data ( ${hbase_data_dir} )? " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    rm -r ${yarn_data_dir}
    rm -r ${hbase_data_dir}
fi


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


print "Setting up public/private keys, use default settings"
ssh-keygen
cat /root/.ssh/id_rsa.pub >>  /root/.ssh/authorized_keys







##########################################################   Installing Hadoop 2.6.0    ####################################################################
printHeader "Installing Hadoop"
print "Downloading Hadoop 2.6.0 ..."

cd $hadoop_dir
wget https://archive.apache.org/dist/hadoop/core/hadoop-2.6.0/hadoop-2.6.0.tar.gz
tar -xzvf hadoop-2.6.0.tar.gz
cd hadoop-2.6.0

print "Setting up configuration files ..."
rm etc/hadoop/core-site.xml
echo "<configuration>
       <property>
              <name>fs.defaultFS</name>
              <value>hdfs://${host_name}:9000</value>
          </property>
      </configuration>
"  >> etc/hadoop/core-site.xml


rm etc/hadoop/hdfs-site.xml
echo "<configuration>
    <property>
         <name>dfs.replication</name>
         <value>1</value>
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


#cp etc/hadoop/mapred-site.xml.template etc/hadoop/mapred-site.xml
rm etc/hadoop/mapred-site.xml
echo "<configuration>
      <property>
              <name>mapreduce.framework.name</name>
              <value>yarn</value>
          </property>

      <property>
          <name>mapreduce.jobhistory.webapp.address</name>
          <value>${host_name}:19888</value>
        </property>
        <property>
          <name>mapreduce.jobhistory.webapp.https.address</name>
          <value>${host_name}:19890</value>
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
          <name>yarn.resourcemanager.webapp.address</name>
          <value>${host_name}:8088</value>
        </property>
        <property>
          <name>yarn.resourcemanager.webapp.https.address</name>
          <value>${host_name}:8090</value>
        </property>

      </configuration>
" >> etc/hadoop/yarn-site.xml

sed -i -e '1iexport JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64\' etc/hadoop/hadoop-env.sh

print "Creating Start/Stop Scripts ..."
rm ${scripts_dir}/hadoop_start.sh
touch ${scripts_dir}/hadoop_start.sh
echo "${hadoop_dir}/hadoop-2.6.0/sbin/start-dfs.sh"                                 >> ${scripts_dir}/hadoop_start.sh
echo "${hadoop_dir}/hadoop-2.6.0/sbin/start-yarn.sh"                                >> ${scripts_dir}/hadoop_start.sh
echo "${hadoop_dir}/hadoop-2.6.0/sbin/mr-jobhistory-daemon.sh start historyserver"  >> ${scripts_dir}/hadoop_start.sh
echo "hadoop dfsadmin -safemode leave"                                              >> ${scripts_dir}/hadoop_start.sh
chmod +x ${scripts_dir}/hadoop_start.sh

rm ${scripts_dir}/hadoop_stop.sh
touch ${scripts_dir}/hadoop_stop.sh
echo "${hadoop_dir}/hadoop-2.6.0/sbin/mr-jobhistory-daemon.sh stop historyserver"  >> ${scripts_dir}/hadoop_stop.sh
echo "${hadoop_dir}/hadoop-2.6.0/sbin/stop-yarn.sh"                                >> ${scripts_dir}/hadoop_stop.sh
echo "${hadoop_dir}/hadoop-2.6.0/sbin/stop-dfs.sh"                                 >> ${scripts_dir}/hadoop_stop.sh
chmod +x ${scripts_dir}/hadoop_stop.sh

# Required to run hadoop commands
export PATH=$PATH:${hadoop_dir}/hadoop-2.6.0/bin/

print "Formatting Namenode ..."
hadoop namenode -format

print "Starting Hadoop Services ..."
${scripts_dir}/hadoop_start.sh




##########################################################   Installing Hbase    ####################################################################
printHeader "Installing Hbase 1.0.2"

cd $hbase_dir

print "Downloading Hbase ..."
wget https://www.apache.org/dist/hbase/hbase-1.0.2/hbase-1.0.2-bin.tar.gz --no-check-certificate

print "Extracting Hbase archive ..."
tar -xzvf hbase-1.0.2-bin.tar.gz
cd hbase-1.0.2

print "Setting up Hbase configuration files ..."
sed -i -e '1iexport JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64\' conf/hbase-env.sh
echo "export HBASE_MANAGES_ZK=true" >> conf/hbase-env.sh

rm conf/hbase-site.xml
echo "<configuration>
      <property>
        <name>hbase.cluster.distributed</name>
        <value>true</value>
      </property>

      <property>
        <name>hbase.rootdir</name>
        <value>hdfs://${host_name}:9000/hbase</value>
      </property>

      <property>
          <name>hbase.zookeeper.quorum</name>
          <value>${host_name}</value>
      </property>


      <property>
          <name>dfs.replication</name>
          <value>1</value>
      </property>

      <property>
         <name>hbase.zookeeper.property.clientPort</name>
         <value>2181</value>
      </property>

      <property>
          <name>hbase.zookeeper.property.dataDir</name>
         <value>${hbase_data_dir}/</value>
      </property>
   </configuration>" >>   conf/hbase-site.xml




print "Creating Hbase Start/Stop Scripts ..."
rm ${scripts_dir}/hbase_start.sh
touch ${scripts_dir}/hbase_start.sh
echo "${hbase_dir}/hbase-1.0.2/bin/start-hbase.sh"                                  >> ${scripts_dir}/hbase_start.sh
chmod +x ${scripts_dir}/hbase_start.sh

rm ${scripts_dir}/hbase_stop.sh
touch ${scripts_dir}/hbase_stop.sh
echo "${hbase_dir}/hbase-1.0.2/bin/stop-hbase.sh"                                  >> ${scripts_dir}/hbase_stop.sh
chmod +x ${scripts_dir}/hbase_stop.sh

print "Starting Hbase ..."
${scripts_dir}/hbase_start.sh





##########################################################   Installing Phoenix 4.5.2   ####################################################################
printHeader "Installing Phoenix 4.5.2"
cd $phoenix_dir

print "Downloading Phoenix ..."
wget http://www.eu.apache.org/dist/phoenix/phoenix-4.5.2-HBase-1.0/bin/phoenix-4.5.2-HBase-1.0-bin.tar.gz
tar -xzvf phoenix-4.5.2-HBase-1.0-bin.tar.gz
cd phoenix-4.5.2-HBase-1.0-bin

print "Copying Phoenix jars into hbase lib dir ..."
cp phoenix-server-4.5.2-HBase-1.0.jar   ${hbase_dir}/hbase-1.0.2/lib/
cp phoenix-core-4.5.2-HBase-1.0.jar     ${hbase_dir}/hbase-1.0.2/lib/

print "Setting up Phoenix launch script ..."
rm ${scripts_dir}/sqlline.sh
touch ${scripts_dir}/sqlline.sh
echo "${phoenix_dir}/phoenix-4.5.2-HBase-1.0-bin/bin/sqlline.py localhost"                                  >> ${scripts_dir}/sqlline.sh
chmod +x ${scripts_dir}/sqlline.sh

print "Restarting Hbase ..."
${scripts_dir}/hbase_stop.sh
${scripts_dir}/hbase_start.sh



##########################################################   Installing Hive 1.2.1   ####################################################################
printHeader "Installing Hive 1.2.1"
cd $hive_dir

# Downloads Apache Hive's Distribution 1.2.1
print "Downloading Apache Hive 1.2.1 ..."
wget http://www.eu.apache.org/dist/hive/stable/apache-hive-1.2.1-bin.tar.gz
tar -xzvf apache-hive-1.2.1-bin.tar.gz
cd apache-hive-1.2.1-bin

#sed -i -e '1iexport HADOOP_HOME=${hadoop_dir}/hadoop-2.6.0\' conf/hive-env.sh




##########################################################   Installing Spark 1.5.1  ####################################################################
printHeader "Installing Spark 1.5.1"
cd $spark_dir

# Downloads Apache Apache Spark 1.5.1
print "Downloading Apache Spark 1.5.1 ..."
wget http://www.eu.apache.org/dist/spark/spark-1.5.1/spark-1.5.1-bin-hadoop2.6.tgz
tar -xzvf spark-1.5.1-bin-hadoop2.6.tgz
cd spark-1.5.1-bin-hadoop2.6

print "Setting up Spark configuration files ..."
echo "
spark.master                     spark://${host_name}:7077
spark.eventLog.enabled           true
spark.eventLog.dir               hdfs://${host_name}:9000/sparkLogs
spark.history.fs.logDirectory    hdfs://${host_name}:9000/sparkLogs
" >> conf/spark-defaults.conf

cp conf/spark-env.sh.template conf/spark-env.sh
sed -i -e '1iexport JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64\' conf/spark-env.sh


print "Creating Spark Start/Stop Scripts ..."
rm ${scripts_dir}/spark_start.sh
touch ${scripts_dir}/spark_start.sh
echo "${spark_dir}/spark-1.5.1-bin-hadoop2.6/sbin/start-master.sh"                                  >> ${scripts_dir}/spark_start.sh
echo "${spark_dir}/spark-1.5.1-bin-hadoop2.6/sbin/start-slave.sh spark://${host_name}:7077"         >> ${scripts_dir}/spark_start.sh
echo "${spark_dir}/spark-1.5.1-bin-hadoop2.6/sbin/start-history-server.sh"                          >> ${scripts_dir}/spark_start.sh
chmod +x ${scripts_dir}/spark_start.sh

rm ${scripts_dir}/spark_stop.sh
touch ${scripts_dir}/spark_stop.sh
echo "${spark_dir}/spark-1.5.1-bin-hadoop2.6/sbin/stop-all.sh"                                  >> ${scripts_dir}/spark_stop.sh
chmod +x ${scripts_dir}/spark_stop.sh


print "Creating spark log dir ..."
hdfs dfs -mkdir hdfs://${host_name}:9000/sparkLogs

print "Starting Spark ..."
${scripts_dir}/spark_start.sh




##########################################################   Setting up Path & Environment Variables  ####################################################################
print "Setting up Path & Environment Variables"

HADOOP_HOME=${hadoop_dir}/hadoop-2.6.0
HBASE_HOME=${hbase_dir}/hbase-1.0.2
HIVE_HOME=${hive_dir}/apache-hive-1.2.1-bin
SPARK_HOME=${spark_dir}/spark-1.5.1-bin-hadoop2.6
SCRIPTS_HOME=${scripts_dir}/
JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/

customPath="${HADOOP_HOME}/bin/:${HBASE_HOME}/bin/:${SCRIPTS_HOME}:${HIVE_HOME}/bin/:${SPARK_HOME}/bin/"


grep -q -F 'export JAVA_HOME=$JAVA_HOME' /etc/environment || echo "export JAVA_HOME=$JAVA_HOME" >> /etc/environment
grep -q -F 'export PATH=$PATH:$customPath' /etc/environment || echo "export PATH=$PATH:$customPath"   >> /etc/environment

grep -q -F 'export HADOOP_HOME=$HADOOP_HOME' /etc/environment || echo "export HADOOP_HOME=$HADOOP_HOME" >> /etc/environment
grep -q -F 'export HBASE_HOME=$HBASE_HOME' /etc/environment || echo "export HBASE_HOME=$HBASE_HOME" >> /etc/environment
grep -q -F 'export HIVE_HOME=$HIVE_HOME' /etc/environment || echo "export HIVE_HOME=$HIVE_HOME" >> /etc/environment
grep -q -F 'export SPARK_HOME=$SPARK_HOME' /etc/environment || echo "export SPARK_HOME=$SPARK_HOME" >> /etc/environment

# Fix for hive class path  Link: http://stackoverflow.com/questions/28997441/hive-startup-error-terminal-initialization-failed-falling-back-to-unsupporte
#grep -q -F 'export HADOOP_USER_CLASSPATH_FIRST=true' /etc/environment || echo "export HADOOP_USER_CLASSPATH_FIRST=true" >> /etc/environment

grep -q -F 'export MAVEN_OPTS="-Xmx1024m -Xms512m -Xss20m"' /etc/environment || echo 'export MAVEN_OPTS="-Xmx1024m -Xms512m -Xss20m"' >> /etc/environment

source /etc/environment

grep -q -F 'source /etc/environment' /root/.bashrc || echo "source /etc/environment" >> /root/.bashrc
grep -q -F 'source /etc/environment' /root/.bashrc || echo "source /etc/environment" >> /root/.bashrc


echo "source /etc/environment" >> /root/.bashrc
echo "source /etc/environment" >> /root/.profile



# Hive Error Fix
# http://stackoverflow.com/questions/28997441/hive-startup-error-terminal-initialization-failed-falling-back-to-unsupporte
# https://cwiki.apache.org/confluence/display/Hive/Hive+on+Spark%3A+Getting+Started
rm ${HADOOP_HOME}/share/hadoop/yarn/lib/jline-0.9.94.jar




jps
print "All Services Installed ..."
