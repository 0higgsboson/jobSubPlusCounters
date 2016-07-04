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
elif [ $# -eq 3 ]
  then
    fieldName=$1
    startDate=$2
    endDate=$3
  else
    echo "Usage 1:  Two arguements are required  fieldName[workloadID, jobName, tag] fieldValue"
    echo "Usage 2:  Three arguements are required  date startDate endDate"
    echo "Date format should be yyyy-MM-dd HH:mm:ss  and startDate < endDate, both dates are inclusive"
    echo "Example:"
    echo './mongo_data_remove.sh date "2016-06-20 15:48:12" "2016-06-20 16:00:28" '
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

elif [[ "${fieldName}" = "tag"  ]];
then
    echo "use ${DB_NAME}"                                                                              >> ${scriptFileName}
    echo "db.getCollection('${COLLECTION_NAME}').remove({\"jobMetaData.tag\":\"${fieldValue}\"})"  >> ${scriptFileName}
    mongo <    ${scriptFileName}

elif [[ "${fieldName}" = "date"  ]];
then
    echo "use ${DB_NAME}"                                                                              >> ${scriptFileName}
    echo "db.getCollection('${COLLECTION_NAME}').remove({\"jobMetaData.startTime\": {\"\$gte\": \"${startDate}\", \"\$lte\": \"${endDate}\"}})"     >> ${scriptFileName}
    mongo <    ${scriptFileName}

else
    echo "Field name not supported ..."
fi


rm ${scriptFileName}


#db.reports.find({},{"jobMetaData.startTime": 1, _id: 1})
#db.reports.find({"jobMetaData.startTime": {"$lt": "2016-06-22 16:00:28"}},{"jobMetaData.startTime": 1, _id: 1})
#db.reports.find({"jobMetaData.startTime": {"$gte": "2016-06-22 15:48:12", "$lt": "2016-06-22 16:00:28"}},{"jobMetaData.startTime": 1, _id: 1})
