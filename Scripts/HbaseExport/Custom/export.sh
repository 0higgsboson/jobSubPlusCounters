#!/bin/bash

printf "Preparing dir strcuture ..."
NOW=$(date +"%Y-%m-%d-%H-%M")
tempDir="Backup-${NOW}"
mkdir $tempDir
cd $tempDir 
CURRENT_DIR=`pwd`

JAR_PATH=/root/sherpa/jobSubPub_src/jobSubPlusCounters/importexport/target/importexport-1.0-jar-with-dependencies.jar

printf "\n\nExporting Tables ..."
java -cp $JAR_PATH com.sherpa.importexport.PhoenixTableExport  ${CURRENT_DIR}/export/  $NOW
printf "\nDone Exporting Tables ..."

printf "\nUploading Data on Google Cloud Storage ..."
gsutil cp -r ${CURRENT_DIR}/export/  gs://hbase-backup/$NOW/


cd ..
rm -r $tempDir

printf "\n Finished ...\n"
