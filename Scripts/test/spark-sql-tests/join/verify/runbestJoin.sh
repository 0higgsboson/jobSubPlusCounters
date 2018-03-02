#!/bin/bash

suffix=0001

co=CPU
tag=join-$co-10-25-2017-$suffix

for i in `seq 1 10` ;
do
    spark-submit -PSManaged=false -Tag=$tag -sherpaCostObj=$co  --conf spark.executor.instances=9 --conf spark.kryoserializer.buffer=83102 --conf spark.shuffle.file.buffer=16000 --conf spark.executor.memory=1024m --conf spark.memory.fraction=0.5 --conf spark.storage.memoryMapThreshold=1259751 --conf spark.reducer.maxSizeInFlight=10000000 --conf spark.memory.storageFraction=0.1 --conf spark.executor.cores=1 --conf spark.yarn.containerLauncherMaxThreads=15 --conf spark.shuffle.sort.bypassMergeThreshold=290 --conf spark.kryoserializer.buffer.max=66 --conf spark.io.compression.snappy.blockSize=30819 --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar join.sql
done


