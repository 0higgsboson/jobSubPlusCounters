#!/bin/bash

# Assumptions
#  1. this script is installed in user home's :  ~/HiBenchSetup
#  2. HiBench will be cloned into ~/HiBenchTest
#  3. 
# 

# Save Script Working Dir
CURRENT_DIR=`pwd`
echo "PWD: $CURRENT_DIR"

# Installs Git if not installed already
echo "checking git install..."
git >> /dev/null
if [ "$?" -ne 0 ]; then
	apt-get install git
fi

# Create a directory to install HiBench
echo "mkdir ~/HiBenchTest"
mkdir ~/HiBenchTest
cd ~/HiBenchTest

# Clones HiBench Project
echo "git clone https://github.com/intel-hadoop/HiBench.git"
git clone https://github.com/intel-hadoop/HiBench.git


echo "cd HiBench"
cd HiBench


# Installs Maven if not installed already
echo "Checking maven install.."
mvn >> /dev/null
if [ "$?" -ne 0 ]; then
	apt-get install maven
fi

# Builds the project
echo "./bin/build-all.sh"
./bin/build-all.sh

# Creates a configuration file
cd conf 
echo "cp ${CURRENT_DIR}/99-user_defined_properties.conf  ~/HiBenchTest/HiBench/conf/99-user_defined_properties.conf"
cp "${CURRENT_DIR}"/99-user_defined_properties.conf  ~/HiBenchTest/HiBench/conf/99-user_defined_properties.conf

# cd to the directory
echo "cd ~/HiBenchSetup"
cd ~/HiBenchSetup


echo "Finished the install of HiBench"

