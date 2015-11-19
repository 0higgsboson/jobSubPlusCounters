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
pdsh -w ^${hosts_file} "mkdir -p $phoenix_dir"
pdsh -w ^${hosts_file} "mkdir -p $scripts_dir"





# Installs Phoenix
#----------------------------------
printHeader "Installing Phoenix ${PHOENIX_VERSION}"
cd $phoenix_dir

print "Downloading Phoenix ${PHOENIX_VERSION} ..."
rm -f phoenix-${PHOENIX_VERSION}-HBase-1.0-bin.tar.gz
wget http://www.eu.apache.org/dist/phoenix/phoenix-${PHOENIX_VERSION}-HBase-1.0/bin/phoenix-${PHOENIX_VERSION}-HBase-1.0-bin.tar.gz
tar -xzvf phoenix-${PHOENIX_VERSION}-HBase-1.0-bin.tar.gz
cd phoenix-${PHOENIX_VERSION}-HBase-1.0-bin

print "Copying Phoenix jars into hbase lib dir on all region servers ..."
pdcp -r -w ^${hosts_file}  phoenix-server-4.5.2-HBase-1.0.jar  ${hbase_dir}/hbase-${HBASE_VERSION}/lib/
pdcp -r -w ^${hosts_file}  phoenix-core-4.5.2-HBase-1.0.jar    ${hbase_dir}/hbase-${HBASE_VERSION}/lib/



print "Setting up Phoenix launch script ..."
rm ${scripts_dir}/sqlline.sh
touch ${scripts_dir}/sqlline.sh
echo "${phoenix_dir}/phoenix-${PHOENIX_VERSION}-HBase-1.0-bin/bin/sqlline.py localhost"                                  >> ${scripts_dir}/sqlline.sh
chmod +x ${scripts_dir}/sqlline.sh

print "Restarting Hbase ..."
${scripts_dir}/hbase_stop.sh
${scripts_dir}/hbase_start.sh


jps
print "All Services Installed ..."