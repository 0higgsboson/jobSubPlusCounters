#!/bin/bash


# DateTime Of Export
# Has to be a valid Backup DateTime, Check on Google Cloud Backup Dir
DT=2015-09-22-14


printf "Preparing dir strcuture ..."
NOW=$(date +"%Y-%m-%d-%H")
tempDir="Backup-${NOW}"
mkdir -p $tempDir/import/
cd $tempDir 
CURRENT_DIR=`pwd`



# Replace the download jar command with local if you have tunecore available locally
printf "\nDownloading tunecore jar ..."
wget https://www.dropbox.com/s/02d88px7ypuoez0/tunecore-1.0-jar-with-dependencies.jar?dl=0
printf "\nDone Downloading tunecore jar ..."


printf "\nDownloading Data From Google Cloud Storage ..."
gsutil cp -r gs://hbase-backup/$DT/export/* ${CURRENT_DIR}/import/



printf "\n\nImporting Tables ..."
java -cp tunecore-1.0-jar-with-dependencies.jar?dl=0 com.sherpa.tunecore.PhoenixTableImport  ${CURRENT_DIR}/import/
printf "\nDone Importing Tables ..."


cd ..
rm -r $tempDir

printf "\n Finished ... \n"
