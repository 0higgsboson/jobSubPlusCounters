#!/bin/bash

# Assumptions
# 1. Default host name is tenzing-red.  If different, update hadoop_cluster_installer to reflect this before running it.
# 2. Copy ssh public key into github

sudo -i
cd ~/jobSubPlusCounters/Scripts/Setup

./hadoop_cluster_installer.sh
source /etc/environment
./sherpa_installer.sh
./datagen.sh
