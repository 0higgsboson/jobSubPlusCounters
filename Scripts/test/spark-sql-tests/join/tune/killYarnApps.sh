#!/bin/bash
 
SERVICE=$1
 
function main {
 
	case "$1" in
		ALL)
		stopAllServices
		;;
 
		*)
		stopInQueue $1
		;;	
	esac
}
 
function stopAllServices {
# Get all the application IDs into the variable 'result' whose state is RUNNING
result=$(yarn application -list -appStates RUNNING | awk 'NR>2 {print $1}')
 
for applicationId in $result
#For all the application IDs, run the yarn kill command
do
yarn application -kill $applicationId
printf "All jobs are killed"
done
 
# Clear spark history logs
hdfs dfs -rm -r -skipTrash /spark-history/*
}
 
function stopInQueue {
#Find the applicaitonId running in the supplied queue name
jobInQueue=$1
applicationId=$(yarn application -list -appStates RUNNING | awk -v tempJob=$jobInQueue '$5 == tempJob {print $1}')
 
 
#If queue name found, kill the application else report the message
if [ ! -z $applicationId ]
then
yarn application -kill $applicationId
sleep 2
hdfs dfs -rm -r -skipTrash /spark-history/$applicationId*
else
printf "Queue name didn't match. Please check your input queue name\n"
 
}
 
main $SERVICE

