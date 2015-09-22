#!/bin/bash

printf "Preparing dir strcuture ..."
output=/sherpa/backup/
hdfs dfs -mkdir -p $output
hdfs dfs -rm -r "${output}/*"
NOW=$(date +"%Y-%m-%d-%H")
tempDir="Backup-${NOW}"
mkdir $tempDir
cd $tempDir 

tables=("COUNTERS" "HIBENCH" "HIBENCHIDS" "SYSTEM.CATALOG" "SYSTEM.FUNCTION" "SYSTEM.SEQUENCE" "SYSTEM.STATS" "WORKLOADIDS" "workloadCounters")
for i in "${tables[@]}"
do
	echo "***************************************** Table $i"
	printf "\nExporting $i ..."
	hbase org.apache.hadoop.hbase.mapreduce.Export $i "${output}/$i"
	printf "\nExported $i Table ..."

	printf "\nMerging & Downloading $i From HDFS ..."
	hdfs dfs -getmerge "${output}/$i/" $i
	printf "\n Done Merging & Downloading $i ..."

	printf "\nUploading on Google Cloud Storage ..."
	printf "\ngsutil cp $i gs://hbase-backup/$i-$NOW"
	gsutil cp $i gs://hbase-backup/$i-$NOW
	printf "\n Done Uploading $i on Google Cloud Storage ...\n"
	echo "*****************************************************************************************************************"
done

cd ..
rm -r $tempDir