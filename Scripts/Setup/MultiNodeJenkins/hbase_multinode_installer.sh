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
pdsh -w ^${hosts_file} "mkdir -p $hbase_dir"
pdsh -w ^${hosts_file} "mkdir -p $scripts_dir"


pdsh -w ^${hosts_file}   "rm -r ${hbase_data_dir}"


# Creates data dir's
print "Creating Data Dir's"
pdsh -w ^${hosts_file}   "mkdir -p ${hbase_data_dir}"





# Installs Hbase
#----------------------------------
printHeader "Installing Hbase"

cd $hbase_dir
cp ${sherpa_repo_dir}/downloads/hbase-${HBASE_VERSION}-bin.tar.gz   ${hbase_dir}/hbase-${HBASE_VERSION}-bin.tar.gz

print "Extracting Hbase archive ..."
tar -xzvf hbase-${HBASE_VERSION}-bin.tar.gz
cd hbase-${HBASE_VERSION}

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
        <name>hbase.regionserver.port</name>
        <value>60020</value>
      </property>

      <property>
        <name>hbase.rootdir</name>
        <value>hdfs://${master}:9000/hbase</value>
      </property>

      <property>
          <name>hbase.zookeeper.quorum</name>
          <value>${master}</value>
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


rm conf/regionservers
cp ${hosts_file} conf/regionservers


# Copies Hbase Files to all hosts
print "Copying Hbase Files to All Hosts ..."
pdsh    -w ^${hosts_file}  -x ${master} "mkdir -p ${hbase_dir}/hbase-${HBASE_VERSION}"
pdcp -r -w ^${hosts_file}  -x ${master} ${hbase_dir}/hbase-${HBASE_VERSION}/ ${hbase_dir}/hbase-${HBASE_VERSION}/



print "Creating Hbase Start/Stop Scripts ..."
rm ${scripts_dir}/hbase_start.sh
touch ${scripts_dir}/hbase_start.sh
echo "${hbase_dir}/hbase-${HBASE_VERSION}/bin/start-hbase.sh"                                  >> ${scripts_dir}/hbase_start.sh
chmod +x ${scripts_dir}/hbase_start.sh

rm ${scripts_dir}/hbase_stop.sh
touch ${scripts_dir}/hbase_stop.sh
echo "${hbase_dir}/hbase-${HBASE_VERSION}/bin/stop-hbase.sh"                                  >> ${scripts_dir}/hbase_stop.sh
chmod +x ${scripts_dir}/hbase_stop.sh

print "Starting Hbase ..."
${scripts_dir}/hbase_start.sh




print "Setting up Path & Environment Variables ..."

# defines HBASE_HOME
defineEnvironmentVar "HBASE_HOME" "${hbase_dir}/hbase-${HBASE_VERSION}"

# adds Hbase bin to Path variable
addToPath "${hbase_dir}/hbase-${HBASE_VERSION}/bin"


jps
print "All Services Installed ..."