#!/bin/bash

printf "\n\n ****************** Generating input data ... \n"
#hdfs dfs -rm -r /teraInput
#yarn jar /root/cluster/hadoop/hadoop-2.6.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar teragen -D PSManaged=false 10000000000 /teraInput






# for i in `seq 1 10`;
 #       do
  #       yarn jar /root/cluster/hadoop/hadoop-2.6.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar terasort -D PSManaged=true  /teraInput4 /teraOutput
   #     done








mb=1048576
split=1024
size=$(($mb*$split))

mapMem=1024
mapCore=1
redCore=1
redMem=1024

reducers=(8 12 16 20 24)


  for red in ${reducers[@]};
  do
    printf "Testing For (Reducers, Reduceer Memory) = ($red, $redMem) \n\n "
    hdfs dfs -rm -r /teraOutput


    yarn jar /root/cluster/hadoop/hadoop-2.6.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar terasort -D PSManaged=false -D mapreduce.max.split.size=${size} \
    -D mapreduce.job.reduces=${red} -D mapreduce.map.memory.mb=${mapMem} -D mapreduce.reduce.memory.mb=${redMem} -D mapreduce.map.cpu.vcores=${mapCore} \
    -D mapreduce.reduce.cpu.vcores=${redCore} /teraInput4 /teraOutput

  done
