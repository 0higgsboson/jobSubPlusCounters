#!/bin/bash

# Configurations
#======================================================================================

# Write permissions required on following dir
INSTALL_DIR=/opt/sherpa/lib/
PACKAGE_DIR=/opt/sherpa/package
CHECK_IN_BASE_DIR=/root/sherpa

# Set to yes to clone repo's
CLONE_REPOS=yes

# Name of sherpa branch to be used for clone/pull for installation
BRANCH_NAME=master

# Set to ssh and push your key into github ssh keys
# Set to anything other than ssh for user/password based repo clone
AUTH_TYPE=ssh

# Manages & restarts (on exit or reboot) process using supervisor
SUPERVISE_PROCESS=yes

HIVE_VERSION=1.2.1


# Mongo DB Configurations
#======================================================================================
db_install=no

#--------------------------------------------------------------------------------------------------------

