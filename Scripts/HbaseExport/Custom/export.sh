#!/bin/bash

printf "Preparing dir strcuture ..."
NOW=$(date +"%Y-%m-%d-%H")
tempDir="Backup-${NOW}"
mkdir $tempDir
cd $tempDir 
CURRENT_DIR=`pwd`

# Replace the download jar command with local if you have tunecore available locally
printf "\nDownloading tunecore jar ..."
wget https://www.dropbox.com/s/02d88px7ypuoez0/tunecore-1.0-jar-with-dependencies.jar?dl=0
printf "\nDone Downloading tunecore jar ..."

printf "\n\nExporting Tables ..."
java -cp tunecore-1.0-jar-with-dependencies.jar?dl=0 com.sherpa.tunecore.PhoenixTableExport  ${CURRENT_DIR}/export/
printf "\nDone Exporting Tables ..."


printf "\nUploading Data on Google Cloud Storage ..."
gsutil cp -r ${CURRENT_DIR}/export/  gs://hbase-backup/$NOW/


cd ..
rm -r $tempDir

printf "\n Finished ...\n"
