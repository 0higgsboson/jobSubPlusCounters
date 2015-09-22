#!/bin/bash

# Format is yyyy-MM-dd-HH
DATE_TIME=2015-09-21-18

printf "Preparing dir strcuture ..."
output=/sherpa/import/
hdfs dfs -mkdir -p $output
hdfs dfs -rm -r "${output}/*"
tempDir="Backup-${DATE_TIME}"
mkdir $tempDir
cd $tempDir 

# Increases Java Heap to avoid Java Heap Error
#export HADOOP_OPTS="-Xmx4096m"
export HADOOP_HEAPSIZE="4096"



tables=("COUNTERS" "HIBENCH" "HIBENCHIDS" "SYSTEM.CATALOG" "SYSTEM.FUNCTION"  "SYSTEM.STATS" "WORKLOADIDS" "workloadCounters")

for i in "${tables[@]}"
do

	echo "********************************************* Importing $i"
        printf "\nDownloading $i From Google Cloud Storage ..."
        printf "\ngsutil cp  gs://hbase-backup/$i-${DATE_TIME} $i"
        gsutil cp  gs://hbase-backup/$i-${DATE_TIME} $i
        printf "\n Done Downloading $i from Google Cloud Storage ..."

        printf "\nUploading $i to HDFS ..."
        hdfs dfs -copyFromLocal $i "${output}/$i" 
        printf "\n Done Uploading to HDFS $i ..."


	printf "\nImporting $i ..."
	hbase org.apache.hadoop.hbase.mapreduce.Import $i "${output}/$i"
	printf "\nImported $i Table ..."

	hdfs dfs -rm -r "${output}/*"
	echo "***** Done Importing $i"

done

cd ..
rm -r $tempDir
echo "******* Finished ..."
