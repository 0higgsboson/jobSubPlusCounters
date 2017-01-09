#!/bin/bash

source configuration_db.sh

date_time=$(date +%Y%m%d%H)

echo "All MongoDB's hosts are [ "${hostname[@]}" ]" > ${logs}/mail_info.log
echo "" >> ${logs}/mail_info.log

for host in ${hostname[@]}
do
   if [ ! -d "${output_path}/$host" ]; then
     mkdir -p ${output_path}/$host
   fi 
   mkdir ${output_path}/$host/${date_time}

   echo ${host}" :" >> ${logs}/mail_info.log
   echo "${database} database updated to central db started at : "$(date +'%Y-%m-%d %H:%M:%S') >> ${logs}/mail_info.log
   start_time=$(date +%H:%M)

   mongodump --host "${host}" --db "${database}" --out "${output_path}/${host}/${date_time}" > ${logs}/${host}_dump_info.log 2>&1
   #cat /root/dbbackup/scripts/logs/dump_info.log > ${logs}/${host}_dump_info.log 2>&1
   status_dump=$?
   if [ $status_dump -eq 0 ]
   then
      container=$host
      #container=$(echo $host |tr "." "-")
      #echo ${container}-${database}-${date_time}
      azure storage container create ${container}-${database}-${date_time}

      for file in $(cd ${output_path}/${host}/${date_time}/${database} && ls)
      do
         azure storage blob upload -q ${output_path}/${host}/${date_time}/${database}/$file ${container}-${database}-${date_time} $file
      done

      if [ ! -d "${restore_path}/$host" ]; then
        mkdir -p ${restore_path}/$host
      fi
      mkdir ${restore_path}/$host/${date_time}
      for file in $(azure storage blob list ${container}-${database}-${date_time} | egrep -v "info| Name | Getting | --" | awk -F" " '{print $2}')
      do
         #echo "Downloading the restoring files..."
         azure storage blob download -q ${container}-${database}-${date_time} $file ${restore_path}/${host}/${date_time}/$file
      done
      #mongorestore --host "${centralhost}" --db "${centraldb}" "${output_path}/${host}" > ${logs}/central_restore_info.log 2>&1
      #mongorestore --host "${centralhost}" --db "${centraldb}" "${restore_path}/${host}" > ${logs}/central_restore_info.log 2>&1
      mongorestore --host "${centralhost}" -u "${username}" -p "${password}" --db "${centraldb}" "${restore_path}/${host}/${date_time}" > ${logs}/central_restore_info.log 2>&1
      #cat /root/dbbackup/scripts/logs/restore_info.log > ${logs}/central_restore_info.log 2>&1
      status_restore=$?
      if [ $status_restore -eq 0 ]
      then 
         echo "${database} database updated to central db end at : "$(date +'%Y-%m-%d %H:%M:%S') >> ${logs}/mail_info.log
         end_time=$(date +%H:%M)

         # feeding variables by using read and splitting with IFS
         IFS=: read old_hour old_min <<< "$start_time"
         IFS=: read hour min <<< "$end_time"

         # convert hours to minutes
         # the 10# is there to avoid errors with leading zeros
         # by telling bash that we use base 10
         total_old_minutes=$((10#$old_hour*60 + 10#$old_min))
         total_minutes=$((10#$hour*60 + 10#$min))

         time_diff=$((total_minutes - total_old_minutes));
         echo "" >> ${logs}/mail_info.log
         echo "Total time taken : ${time_diff} mins" >> ${logs}/mail_info.log

         echo "" >> ${logs}/mail_info.log

         echo "The following collections for ${database} were backed up for ${host} : " >> ${logs}/mail_info.log
         echo "" >> ${logs}/mail_info.log
         echo "Collection Name                        Total Number of Documents" >> ${logs}/mail_info.log
         #cat ${PWD}/logs/dump_info.log | egrep "Date|done dumping" | awk -F" " '{print $4 $5 $6}' | mail -s "${subject_dump}" "${receivers}"
         cat ${logs}/${host}_dump_info.log | grep "done dumping" | awk -F" " '{print $4"          -       "substr($5,2)" Document(s)"}' >> ${logs}/mail_info.log
         echo "" >> ${logs}/mail_info.log
         echo "The following collections for ${centraldb} are updated in central Db(${centralhost}) : " >> ${logs}/mail_info.log
         echo "" >> ${logs}/mail_info.log
         echo "Collection Name                  Total Number of Documents" >> ${logs}/mail_info.log

         cat ${logs}/central_restore_info.log | grep "finished restoring" | awk -F" " '{ print $4 "       -       "substr($5,2) " Document(s)" }' >> ${logs}/mail_info.log
         echo "" >> ${logs}/mail_info.log
         echo "The above database dump stored at https://${AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/${container}-${database}-${date_time}/" >> ${logs}/mail_info.log
         echo "" >> ${logs}/mail_info.log
         echo "" >> ${logs}/mail_info.log
#         echo "Thanks," >> ${logs}/mail_info.log
#         echo "Chinna." >> ${logs}/mail_info.log
      fi
   fi

   rm -rf ${output_path}/$host/${date_time}
   rm -rf ${restore_path}/$host/${date_time}
done

echo "" >> ${logs}/mail_info.log
echo "Thanks," >> ${logs}/mail_info.log
echo "Chinna." >> ${logs}/mail_info.log
cat ${logs}/mail_info.log | /usr/bin/mail -r "${sender}" -s "All MongoDB's are updated to central MongoDB : <$(date +'%Y-%m-%d %H:%M:%S')>" "${receivers}"
#else
   #echo "Failed to create the dump ${output_path} file." | mail -s "Mongo Backup : <$(date +'%Y-%m-%d %H:%M:%S')>" "${receivers}"
#   echo "fail"
#fi
