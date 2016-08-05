#!/bin/bash

now=$(date +"%Y_%d_%m_%H_%M_%s")
examplesJar="/root/cluster/hadoop/hadoop-2.7.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar"
yarn jar $examplesJar terasort -D Tag=terasort-018 /tsinput10GB/ /tsoutput/$now 
hadoop fs -rm /tsoutput/$now/*

