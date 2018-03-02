#!/bin/sh
/opt/cloudera/parcels/SPARK2-2.1.0.cloudera2-1.cdh5.7.0.p0.171658/lib/spark2/bin/spark-submit  -D spark.executor.instances=8 -D spark.kryoserializer.buffer=121054 -D spark.shuffle.file.buffer=85080 -D spark.executor.memory=3309m -D spark.memory.fraction=0.5610830662586406 -D spark.storage.memoryMapThreshold=2117701 -D spark.reducer.maxSizeInFlight=119121699 -D spark.memory.storageFraction=0.22100208362695248 -D spark.executor.cores=1 -D spark.yarn.containerLauncherMaxThreads=22 -D spark.shuffle.sort.bypassMergeThreshold=160 -D spark.kryoserializer.buffer.max=87 -D spark.io.compression.snappy.blockSize=55517 --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar joinXXX.sql;
hadoop fs -rm -r -skipTrash /user/root/SQLTest/Output/RUJXXX;
find / -name \*.sst -exec rm -f {} \;

