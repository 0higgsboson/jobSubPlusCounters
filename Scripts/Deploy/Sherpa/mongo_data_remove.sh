#!/bin/bash

# Configurations
# ------------------------------------------------------------------------------------
DB_NAME=sherpa
COLLECTION_NAME=reports
# ------------------------------------------------------------------------------------


scriptFileName=mongoDeleteScript.js
rm ${scriptFileName}

if [ $# -eq 2 ]
  then
    fieldName=$1
    fieldValue=$2
  else
    echo "Usage:  Two arguements are required  fieldName[workloadID, jobName] fieldValue"
    exit
fi


if [[ "${fieldName}" = "workloadID"  ]];
then
    echo "use ${DB_NAME}"                                                                               >> ${scriptFileName}
    echo "db.getCollection('${COLLECTION_NAME}').remove({workloadID:\"${fieldValue}\"})"                  >> ${scriptFileName}
    mongo <    ${scriptFileName}

elif [[ "${fieldName}" = "jobName"  ]];
then
    echo "use ${DB_NAME}"                                                                              >> ${scriptFileName}
    echo "db.getCollection('${COLLECTION_NAME}').remove({\"jobMetaData.jobName\":\"${fieldValue}\"})"  >> ${scriptFileName}
    mongo <    ${scriptFileName}

else
    echo "Field name not supported ..."
fi


rm ${scriptFileName}