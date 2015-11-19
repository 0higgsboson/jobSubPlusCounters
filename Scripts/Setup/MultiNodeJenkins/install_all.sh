#!/bin/bash

# Assumptions
# 1. Use root account
# 2. First node of hosts file will be treated as master node
# 3. Public/Private keys should already be set up

if [ "$#" -ne 1 ]; then
    echo "Usage: hosts_file_path"
    exit
fi

hosts_file=$1



# includes configurations
source configurations.sh



./scripts/hadoop_multinode_installer.sh     ${hosts_file}

./scripts/hbase_multinode_installer.sh      ${hosts_file}

./scripts/phoenix_multinode_installer.sh    ${hosts_file}

./scripts/hive_multinode_installer.sh       ${hosts_file}

./scripts/spark_multinode_installer.sh      ${hosts_file}


printf "\n\n Installed All Services "