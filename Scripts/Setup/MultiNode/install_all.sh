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

hadoop_multinode_installer.sh     ${hosts_file}

hbase_multinode_installer.sh      ${hosts_file}

phoenix_multinode_installer.sh    ${hosts_file}

hive_multinode_installer.sh       ${hosts_file}

spark_multinode_installer.sh      ${hosts_file}


printf "\n\n Installed All Services "