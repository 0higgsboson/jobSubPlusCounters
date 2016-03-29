#!/bin/bash

# Assumptions
# 1. Public/Private keys should already be set up

if [ "$#" -ne 1 ]; then
    echo "Usage: hosts_file_path"
    exit
fi

hosts_file=$1


# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`
echo "Current Working Dir: ${CWD}"

# load configurations & utils functions
source "${CWD}"/configurations.sh
source "${CWD}"/utils.sh

installPdsh      ${hosts_file}
installPreReqs   ${hosts_file}

print "Copying Files ..."
pdsh -w ^${hosts_file} "mkdir -p ${tmp_path}/"
pdcp -r -w ^${hosts_file}  ${CWD}/ ${tmp_path}/

printHeader " Running Installer ..."
pdsh -w ^${hosts_file} "${tmp_path}/setup.sh"


print "Cleaning-up Tmp Files ..."
pdsh -w ^${hosts_file} "rm -r ${tmp_path}/"
