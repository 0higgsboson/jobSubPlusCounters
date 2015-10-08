#!/bin/bash


# DateTime Of Export
# Has to be a valid Backup DateTime, Check on Google Cloud Backup Dir
DT=2015-09-22-14


printf "Preparing dir strcuture ..."
NOW=$(date +"%Y-%m-%d-%H-%M")
tempDir="Backup-${NOW}"
mkdir -p $tempDir/import/
cd $tempDir 
CURRENT_DIR=`pwd`


JAR_PATH=/root/tunecore-1.0-jar-with-dependencies.jar

printf "\nDownloading Data From Google Cloud Storage ..."
gsutil cp -r gs://hbase-backup/$DT/export/* ${CURRENT_DIR}/import/



printf "\n\nImporting Tables ..."
java -cp $JAR_PATH com.sherpa.tunecore.PhoenixTableImport  ${CURRENT_DIR}/import/   $NOW
printf "\nDone Importing Tables ..."


cd ..
rm -r $tempDir

printf "\n Finished ... \n"
