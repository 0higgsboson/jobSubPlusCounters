#!/bin/bash

#Force file syncronization and lock writes
#mongo admin --eval "printjson(db.fsyncLock())"

# User name to use for ssh access
SSH_USER=root

# History server backup dir path
# SSH user should have write permissions to the following dir
HISTORY_SERVER_BACKUP_DIR=/opt/sherpa/historyserver


# Local Mongo DB configurations
LOCAL_SERVER_MONGO_HOST="tenzing"
LOCAL_SERVER_MONGO_PORT="27017"
LOCAL_SERVER_MONGO_DATABASE="sherpa"

# History Server Mongo DB configurations
HISTORY_SERVER_MONGO_HOST="datawarehouse-vm"
HISTORY_SERVER_MONGO_PORT="27017"
HISTORY_SERVER_MONGO_DATABASE="${LOCAL_SERVER_MONGO_HOST}"

# Appends timestamp to backup
TIMESTAMP=`date +%F-%H%M`

# creates a tmp dir
mkdir ${TIMESTAMP}
cd ${TIMESTAMP}

# Defines file name using host and timestamp
FILE=mongodb-$LOCAL_SERVER_MONGO_HOST-$TIMESTAMP

# History Server dir location for backup
DIR=${HISTORY_SERVER_BACKUP_DIR}/${LOCAL_SERVER_MONGO_HOST}


echo "File Name: ${FILE}"
echo "History Server Dir Location: ${DIR}"


# Create backup
echo "Taking backup of DB: ${LOCAL_SERVER_MONGO_DATABASE}"
mongodump --host=$LOCAL_SERVER_MONGO_HOST --port=$LOCAL_SERVER_MONGO_PORT --db=$LOCAL_SERVER_MONGO_DATABASE
echo "Done taking backup ..."


# renames backup file & zips it
mv dump ${FILE}
tar -czf ${FILE}.tar  ${FILE}


#Unlock database writes
#mongo admin --eval "printjson(db.fsyncUnlock())"

echo "Uploading backup to history server ..."
ssh ${SSH_USER}@${HISTORY_SERVER_MONGO_HOST} "mkdir -p ${DIR}/"
scp ${FILE}.tar ${SSH_USER}@${HISTORY_SERVER_MONGO_HOST}:${DIR}/
ssh ${SSH_USER}@${HISTORY_SERVER_MONGO_HOST} "tar -xzvf ${DIR}/${FILE}.tar -C ${DIR}"
echo "Backup uploading done ..."

echo "Restoring backup on history server ..."
ssh ${SSH_USER}@${HISTORY_SERVER_MONGO_HOST} "cd ${DIR};
                                             mongorestore  --db ${HISTORY_SERVER_MONGO_DATABASE}  ${FILE}/${LOCAL_SERVER_MONGO_DATABASE}"
echo "Backup restored on history server ..."

cd ..
rm -r ${TIMESTAMP}


echo "Backup done successfully ..."

