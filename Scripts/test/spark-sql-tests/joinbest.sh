#!/bin/bash

source ./configs.sh

sleep 20;

for i in `seq 1 30` ; do

        /opt/cloudera/parcels/SPARK2-2.1.0.cloudera2-1.cdh5.7.0.p0.171658/lib/spark2/bin/spark-submit --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar join.sql;

        sleep 40;

	/opt/cloudera/parcels/SPARK2-2.1.0.cloudera2-1.cdh5.7.0.p0.171658/lib/spark2/bin/spark-submit --conf spark.executor.instances=17 --conf spark.kryoserializer.buffer=94620 --conf spark.shuffle.file.buffer=77628 --conf spark.executor.memory=3056m --conf spark.memory.fraction=0.703 --conf spark.storage.memoryMapThreshold=1738735 --conf spark.reducer.maxSizeInFlight=70484973 --conf spark.memory.storageFraction=0.11569743911336035 --conf spark.executor.cores=1 --conf spark.yarn.containerLauncherMaxThreads=18 --conf spark.shuffle.sort.bypassMergeThreshold=165 --conf spark.kryoserializer.buffer.max=81 --conf spark.io.compression.snappy.blockSize=42584 --conf spark.hadoop.yarn.timeline-service.enabled=false --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar join.sql;

    if (($i%6 == 0)); then
      sleep 120;
      continue;
    fi

    sleep 40;
done

exit;

/opt/cloudera/parcels/SPARK2-2.1.0.cloudera2-1.cdh5.7.0.p0.171658/lib/spark2/bin/spark-submit --conf spark.executor.instances=17 --conf spark.kryoserializer.buffer=94620 --conf spark.shuffle.file.buffer=77628 --conf spark.executor.memory=3056m --conf spark.memory.fraction=0.703 --conf spark.storage.memoryMapThreshold=1738735 --conf spark.reducer.maxSizeInFlight=70484973 --conf spark.memory.storageFraction=0.11569743911336035 --conf spark.executor.cores=1 --conf spark.yarn.containerLauncherMaxThreads=18 --conf spark.shuffle.sort.bypassMergeThreshold=165 --conf spark.kryoserializer.buffer.max=81 --conf spark.io.compression.snappy.blockSize=42584 --conf spark.hadoop.yarn.timeline-service.enabled=false --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar join.sql;

# spark-submit -PSManaged=false -Tag=$tag -sherpaCostObj=$co --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar join.sql

# good.  spark-submit  --conf spark.executor.instances=10 --conf spark.kryoserializer.buffer=80095 --conf spark.shuffle.file.buffer=52776 --conf spark.executor.memory=2325 --conf spark.memory.fraction=0.5989689545477891 --conf spark.storage.memoryMapThreshold=3115121 --conf spark.reducer.maxSizeInFlight=96372424 --conf spark.memory.storageFraction=0.2164756111153969 --conf spark.executor.cores=1 --conf spark.yarn.containerLauncherMaxThreads=19 --conf spark.shuffle.sort.bypassMergeThreshold=215 --conf spark.kryoserializer.buffer.max=83 --conf spark.io.compression.snappy.blockSize=46999  --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar join.sql

# spark-submit  --conf spark.executor.instances=10 --conf spark.kryoserializer.buffer=80095 --conf spark.shuffle.file.buffer=52776 --conf spark.executor.memory=2325 --conf spark.memory.fraction=0.5989689545477891 --conf spark.storage.memoryMapThreshold=3115121 --conf spark.reducer.maxSizeInFlight=96372424 --conf spark.memory.storageFraction=0.2164756111153969 --conf spark.executor.cores=1 --conf spark.yarn.containerLauncherMaxThreads=19 --conf spark.shuffle.sort.bypassMergeThreshold=215 --conf spark.kryoserializer.buffer.max=83 --conf spark.io.compression.snappy.blockSize=46999 -PSManaged=false -Tag=join-CPU-5GB-02-08-2018-003 --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar join.sql

# -D spark.executor.instances=10 -D spark.kryoserializer.buffer=80095 -D spark.shuffle.file.buffer=52776 -D spark.executor.memory=2325 -D spark.memory.fraction=0.5989689545477891 -D spark.storage.memoryMapThreshold=3115121 -D spark.reducer.maxSizeInFlight=96372424 -D spark.memory.storageFraction=0.2164756111153969 -D spark.executor.cores=1 -D spark.yarn.containerLauncherMaxThreads=19 -D spark.shuffle.sort.bypassMergeThreshold=215 -D spark.kryoserializer.buffer.max=83 -D spark.io.compression.snappy.blockSize=46999

# /opt/cloudera/parcels/SPARK2-2.1.0.cloudera2-1.cdh5.7.0.p0.171658/lib/spark2/bin/spark-submit --conf spark.kryoserializer.buffer.max=128 --conf spark.shuffle.sort.bypassMergeThr        eshold=400 --conf spark.executor.memory=4000m --conf spark.reducer.maxSizeInFlight=200000000 --conf spark.memory.fraction=0.8 --conf spark.yarn.containerLauncherMaxThreads=30 --        conf spark.storage.memoryMapThreshold=4000000 --conf spark.memory.storageFraction=0.55 --conf spark.io.compression.snappy.blockSize=64000 --conf spark.executor.cores=3 --conf sp        ark.shuffle.file.buffer=128000 --conf spark.kryoserializer.buffer=128000 --conf spark.executor.instances=41 --conf spark.hadoop.yarn.timeline-service.enabled=false --class com.s        herpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar join.sql

