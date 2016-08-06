#!/bin/bash

examplesJar="/root/cluster/hadoop/hadoop-2.7.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar"
tag1="terasort-036-10GB-"
inputData="/tsinput10GB"
outputData="/tsoutput"
moduloNum=1 # out of every these runs, one is unmanaged
maxIters=400
numTests=5 # different tests
sleepSeconds=240
preSleepSeconds=600

sleep $preSleepSeconds

for i in `seq 1 $maxIters`; 
do

    let "k = i%numTests"
    tag=$tag1$k
    echo $tag

    now=$(date +"%Y_%d_%m_%H_%M_%s")
    echo "submission " $i
    date

    if (( $i%$moduloNum == 1))
    then 
      echo "nohup yarn jar $examplesJar terasort -D PSManaged=false -D Tag=$tag $inputData/ $outputData/$i > /dev/null & 2>&1"
      nohup yarn jar $examplesJar terasort -D PSManaged=false -D Tag=$tag $inputData/ $outputData/$i > /dev/null & 2>&1
      echo "Unmanaged"
    else
      echo "nohup yarn jar $examplesJar terasort -D PSManaged=true  -D mapreduce.terasort.simplepartitioner=true -D Tag=$tag $inputData/ $outputData/$i > /dev/null & 2>&1"
      nohup yarn jar $examplesJar terasort -D PSManaged=true  -D mapreduce.terasort.simplepartitioner=true -D Tag=$tag $inputData/ $outputData/$i > /dev/null & 2>&1
      echo "Managed"
    fi

    sleep $sleepSeconds 
    hadoop fs -rm /$outputData/$i/*

done


