#!/bin/bash

# Configurations
#======================================================================================

# Write permissions required on following dir
INSTALL_DIR=/opt/sherpa/lib/


# Hadoop Version  (2.7.1 or 2.6.0)
HADOOP_VERSION=2.7.2

HIVE_VERSION=1.2.1

# Set to yes to clone repo's
CLONE_REPOS=yes
BRANCH_NAME=master

# Set to ssh and push your key into github ssh keys for ssh based clone
# Set to anything other than ssh for user/password based repo clone
AUTH_TYPE=ssh

# Manages & restarts (on exit or reboot) process using supervisor
SUPERVISE_PROCESS=yes



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
tenzing_src_dir="${installation_base_dir}/tenzing_src"
clientagent_src_dir="${installation_base_dir}/clientagent_src"


# Client Agent Configurations
#======================================================================================
client_agent_install=yes

# hostname where to install client agent
client_agent_host=client-agent

client_agent_install_dir=/opt/sherpa/ClientAgent/

client_agent_property_file=sherpa.properties

client_agent_executable_file=ClientAgent-1.0-jar-with-dependencies.jar


# Tenzing Configurations
#======================================================================================
tenzing_install=yes

# hostname where to install tenzing
tenzing_host=tenzing

tenzing_install_dir=/opt/sherpa/Tenzing/

tenzing_property_file=sherpa.properties

tenzing_executable_file=Tenzing-1.0-jar-with-dependencies.jar

tuned_params_file=tunedparams.json


# Mongo DB Configurations
#======================================================================================
db_install=no
db_install_file=db_installer.sh


#--------------------------------------------------------------------------------------------------------

