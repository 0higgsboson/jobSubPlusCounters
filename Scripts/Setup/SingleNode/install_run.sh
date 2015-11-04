#!/bin/bash

# Assumptions
# 1. Default host name is tenzing-red.  If different, update hadoop_cluster_installer to reflect this before running it.

sudo -i
./hadoop_cluster_installer.sh
source /etc/environment
./sherpa_installer.sh


