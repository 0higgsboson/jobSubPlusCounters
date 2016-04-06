#!/bin/bash


# Hadoop Version Specific Configurations
#======================================================================================

# For Hadoop 2.7.1
#-------------------------
HADOOP_VERSION=2.7.1
ACTIVE_PROFILE=H2.7.1
MR_REPO_URL=https://github.com/0higgsboson/hadoop2.7.git
SRC_DIR=hadoop2.7


# For Hadoop 2.6.0
#-------------------------
#HADOOP_VERSION=2.6.0
#activeProfile=H2.6
#MR_REPO_URL=https://github.com/0higgsboson/mrClient.git
#SRC_DIR=mrClient


CLONE_REPOS=no



# Paths & Env Variables
#======================================================================================

# Clients (MR & Hive) Configurations
installation_base_dir=/root/sherpa
hive_home=/root/cluster/hive/apache-hive-1.2.1-bin
hadoop_home=/root/cluster/hadoop/hadoop-${HADOOP_VERSION}
scripts_home=/root/scripts
export PATH=$PATH:$hadoop_home/bin

mr_client_src_dir="${installation_base_dir}/mr_client_src/"
hive_client_src_dir="${installation_base_dir}/hive_client_src"
hadoop_src_dir="${installation_base_dir}/hadoop_src"
sherpa_src_dir="${installation_base_dir}/jobSubPub_src"
common_src_dir="${installation_base_dir}/tzCtCommon"






# Client Agent Configurations
#======================================================================================
client_agent_install=yes

# hostname where to install client agent
client_agent_host=test-w2

client_agent_install_dir=/opt/sherpa/ClientAgent/

client_agent_property_file=sherpa.properties

client_agent_executable_file=TzCtCommon-1.0-jar-with-dependencies.jar



# Tenzing Configurations
#======================================================================================
tenzing_install=yes

# hostname where to install tenzing
tenzing_host=test-w1

tenzing_install_dir=/opt/sherpa/Tenzing/

tenzing_property_file=sherpa.properties

tenzing_executable_file=TzCtCommon-1.0-jar-with-dependencies.jar

tuned_params_file=tunedparams.json



#--------------------------------------------------------------------------------------------------------

