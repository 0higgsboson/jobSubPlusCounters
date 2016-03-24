#!/bin/bash

# Client Agent Configurations
#======================================================================================
# yes value will turn on
client_agent_install=yes
# hostname where to install client agent
client_agent_host=test-w2
client_agent_install_dir=/opt/sherpa/ClientAgent/
# property file path: copy from jobSubPlus repo's core module, located under resources. Modify as per your environment and place on this path
client_agent_property_file=/opt/sherpa.properties
# client agent executable path
client_agent_executable_file=/root/sherpa/tzCtCommon/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar



# Tenzing Configurations
#======================================================================================
# yes value will turn on
tenzing_install=yes
# hostname where to install tenzing.  (Note: client agent reads tenzing host property from its local deployed property file at /opt/sherpa.properties, client agent should use following property instead)
tenzing_host=test-w1
tenzing_install_dir=/opt/sherpa/Tenzing/
# property file path: copy from jobSubPlus repo's core module, located under resources. Modify as per your environment and place on this path
tenzing_property_file=/opt/sherpa.properties
# tenzing executable path
tenzing_executable_file=/root/sherpa/tzCtCommon/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar
# tuned params path
tuned_params_file=/root/sherpa/jobSubPub_src/jobSubPlusCounters/Scripts/HiBenchSetupAndTestScripts/tunedparams.json




# Clients (MR & Hive) Configurations
installation_base_dir=/root/sherpa
hive_home=/root/cluster/hive/apache-hive-1.2.1-bin
hadoop_home=/root/cluster/hadoop/hadoop-2.6.0
scripts_home=/root/scripts
export PATH=$PATH:$hadoop_home/bin

mr_client_src_dir="${installation_base_dir}/mr_client_src"
hive_client_src_dir="${installation_base_dir}/hive_client_src"
hadoop_src_dir="${installation_base_dir}/hadoop_src"
sherpa_src_dir="${installation_base_dir}/jobSubPub_src"
common_src_dir="${installation_base_dir}/tzCtCommon"

#--------------------------------------------------------------------------------------------------------

