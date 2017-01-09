#!/bin/bash

#Db details
#centralhost="52.160.97.151"
centralhost="tenzing-backup"
centraldb="sherpa"
username="sherpa"
password="Wq9KEK4Qn1"

hostname=("azure-demo1-03" "azure-cicd1-03")
#hostname=("13.93.157.231" "40.78.25.35")
#hostname=("13.93.157.231" "13.93.157.232")
database="sherpa"
#port=27017

output_path="/root/dbbackup/scripts/downloadData/"
restore_path="/root/dbbackup/scripts/restoreData/"
logs="/root/dbbackup/scripts/logs"

sender="chinna@theperformancesherpa.com"
#receivers="chinna@theperformancesherpa.com"
#receivers="sudheer@theperformancesherpa.com,chinna@theperformancesherpa.com"
receivers="sid@theperformancesherpa.com,sudheer@theperformancesherpa.com,chinna@theperformancesherpa.com,ismail@theperformancesherpa.com"
#subject_dump="Backup of Sherpa DB"
#subject_restore="Restore of Sherpa DB"

#Azure storage details
export AZURE_STORAGE_ACCOUNT="mongobackup"
export AZURE_STORAGE_ACCESS_KEY="MGI1TqsW5B7TXD70fjiOtsjzwhmi8zb0BmTB/YcW6WUWF1QXIPvuYRtgM6rMVcTSd96ws5J+3dz8pXvsVE7cgw=="

#myshare="mongobackupshare"
#mydir="sherpa"

#container_name="sherpacontainer"
