#!/bin/bash

now=$(date +"%Y_%d_%m_%H_%M_%s")
examplesJar="/root/cluster/hadoop/hadoop-2.7.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar"
yarn jar $examplesJar wordcount -D Tag=wordcount-MR-example-024 /holmesinput/ /holmesoutput/$now 
hadoop fs -rm /holmesoutput/$now/*

