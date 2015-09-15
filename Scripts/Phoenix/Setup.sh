#!/bin/bash


# This script assumes public key of node running that script has been added in authorized_key on rest of the nodes

# Before you run that script
# Make sure you CDH version is correct
# Change machine numbers and prefix, this script assumes node1, node2, .... node29


# Defines Cloudera's CDH Version
CDH_VERSION=CDH-5.4.5-1.cdh5.4.5.p0.7

CURRENT_DIR=`pwd`
mkdir PhoenixInstallaer
cd    PhoenixInstallaer

wget https://www.dropbox.com/s/9sjpzgr7wvnxuih/PhoenixClouderaRelease-5.4.4.tar.gz?dl=1;
tar -xzvf PhoenixClouderaRelease-5.4.4.tar.gz\?dl\=1;
cd PhoenixClouderaRelease-5.4.4/phoenix-4.5.1-HBase-1.0-bin/;


# Set initial node number here
a=1

# Set last node number here, i.e. 29
while [ $a -le 29 ]
do

   # change prefix from node to whatever is required
   machine="node"$a
   printf "\n\n\n *********** Copying Phoenix jars on $machine ....\n"

   printf "Copying Hbase Server Jar ..."
   scp phoenix-4.5.1-HBase-1.0-server.jar root@"${machine}":/opt/cloudera/parcels/${CDH_VERSION}/lib/hbase/lib/

   printf "\nCopying Phoenix Core Jar ..."
   scp phoenix-core-4.5.1-HBase-1.0.jar root@"${machine}":/opt/cloudera/parcels/${CDH_VERSION}/lib/hbase/lib/

   ssh root@"${machine}" " export CDH_VERSION=CDH-5.4.5-1.cdh5.4.5.p0.7;

                           sudo ls -ls /opt/cloudera/parcels/${CDH_VERSION}/lib/hbase/lib/phoenix-4.5.1-HBase-1.0-server.jar;

                           sudo ls -ls /opt/cloudera/parcels/${CDH_VERSION}/lib/hbase/lib/phoenix-core-4.5.1-HBase-1.0.jar;
                        "

   a=`expr $a + 1`
done


printf "\n Cleaning up temp dir's ..."
cd $CURRENT_DIR
rm -r PhoenixInstallaer

printf "\n Please Restart Hbase Cluster to finish the installation \n\n"

