#!/bin/bash
#Usage:  S3toHdfs.sh   S3_Path  Hdfs_Path   
# ./S3toHdfs.sh  s3://perfsherp.smallFiles/testData/ /data/
# Assumptions:  S3Cmd utils are installed and on path
if [ "$#" -ne 2 ]; then
    echo "Usage:  S3toHdfs.sh   S3_Path  Hdfs_Path"
    exit 1
fi


# temporary dir name
temp=/root/TestsData/
# S3 path
src=$1
# HDFS path
dst=$2
# create a temporary dir
mkdir -p $temp

#echo "Installing S3 Command line utility ..."
#wget http://s3tools.org/repo/deb-all/stable/s3cmd_1.0.0.orig.tar.gz
#tar -xzvf s3cmd_1.0.0.orig.tar.gz
#cd s3cmd-1.0.0/

echo "Copying Data From $src to $temp"
s3cmd get --recursive $src $temp
echo "Data Copied from S3 to local ..."
echo "Uploading data on HDFS ..."
hdfs  dfs -mkdir -p $dst
hdfs  dfs -copyFromLocal $temp/* $dst
echo "Data Copied to HDFS ..."
#rm -r $temp
echo "Finished Task ..."
