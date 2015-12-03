#!/bin/bash

echo "Generating input data ..."
hdfs dfs -rm -r /teraInput
yarn jar /root/cluster/hadoop/hadoop-2.6.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar teragen 100000000 /teraInput


mb=1048576
split=128
size=$(($mb*$split))

mapMem=256
redMem=512
mapCore=1
redCore=1

mappers=(1 2 4 8 16 20)
reducers=(1 4 8 12)


for map in ${mappers[@]};
do
  for red in ${reducers[@]};
  do
    printf "Testing For (Mappers, Reducers) = ($map, $red) \n\n "
    hdfs dfs -rm -r /teraOutput

    echo "yarn jar /root/cluster/hadoop/hadoop-2.6.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar terasort -D PSManaged=false -D mapreduce.max.split.size=${size} -D mapreduce.job.reduces=${red} -D mapreduce.map.memory.mb=${mapMem} -D mapreduce.reduce.memory.mb=${redMem} -D mapreduce.map.cpu.vcores=${mapCore} -D mapreduce.reduce.cpu.vcores=${redCore} /teraInput /teraOutput"
    yarn jar /root/cluster/hadoop/hadoop-2.6.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0.jar terasort -D PSManaged=false -D mapreduce.max.split.size=${size} -D mapreduce.job.reduces=${red} -D mapreduce.map.memory.mb=${mapMem} -D mapreduce.reduce.memory.mb=${redMem} -D mapreduce.map.cpu.vcores=${mapCore} -D mapreduce.reduce.cpu.vcores=${redCore} /teraInput /teraOutput

  done
done