#!/bin/bash

host=104.197.39.14
user=root

if [ "$#" -ne 1 ]; then
    echo "Usage: repo_name"
    exit
fi

repo_name=$1
echo "Syncing Repo ${repo_name}"

src_jobsubplus=/root/sherpa/jobSubPub_src/jobSubPlusCounters/
src_tzctcommon=/root/sherpa/tzCtCommon/TzCtCommon/
src_tenzing=/root/sherpa/tenzing_src/Tenzing/
src_ca=/root/sherpa/clientagent_src/ClientAgent/
src_mr=/root/sherpa/mr_client_src/hadoop2.7/
src_hive=/root/sherpa/hive_client_src/hiveClientSherpa/

dst_jobsubplus=/root/sherpa/jobSubPub_src/jobSubPlusCounters/
dst_tzctcommon=/root/sherpa/tzCtCommon/TzCtCommon/
dst_tenzing=/root/sherpa/tenzing_src/Tenzing/
dst_ca=/root/sherpa/clientagent_src/ClientAgent/
dst_mr=/root/sherpa/mr_client_src/hadoop2.7/
dst_hive=/root/sherpa/hive_client_src/hiveClientSherpa/

src=""
dst=""

if [[ "${repo_name}" = "jobsub"  ]]; then
    src=${src_jobsubplus}
    dst=${dst_jobsubplus}
elif [[ "${repo_name}" = "common"  ]]; then
    src=${src_tzctcommon}
    dst=${dst_tzctcommon}
elif [[ "${repo_name}" = "tz"  ]]; then
    src=${src_tenzing}
    dst=${dst_tenzing}
elif [[ "${repo_name}" = "ca"  ]]; then
    src=${src_ca}
    dst=${dst_ca}
elif [[ "${repo_name}" = "mr"  ]]; then
    src=${src_mr}
    dst=${dst_mr}
elif [[ "${repo_name}" = "hive"  ]]; then
    src=${src_hive}
    dst=${dst_hive}
else
    echo "Error: Repo name not supported ..."
    exit
fi

echo "Host: ${host}"
echo "User: ${user}"
echo "Source: ${src}"
echo "Dst: ${dst}"


rsync -vhrz --progress --delete --exclude 'target/*'  --exclude '*/target' --exclude '*.jar' --exclude '*.war' --exclude '*.class' --exclude '.git/'  ${src}  ${user}@${host}:${dst}
