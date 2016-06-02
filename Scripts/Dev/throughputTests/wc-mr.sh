#!/bin/bash

HADOOP_VERSION=2.7.1
EBOOKS=40-gutenberg-books

hadoop fs -mkdir /input
hadoop fs -copyFromLocal ./$EBOOKS /input/

for i in `seq 1 50` ;
do
    hadoop fs -rm -r /output/$EBOOKS
    yarn jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-$HADOOP_VERSION.jar wordcount -D PSManaged=true -D Tag=wordcount-MR-example /input/$EBOOKS /output/$EBOOKS
done


