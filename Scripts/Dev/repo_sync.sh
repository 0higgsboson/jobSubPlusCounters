#!/bin/bash

host=104.197.39.14
user=root

if [ "$#" -ne 1 ]; then
    echo "Usage: repo_name"
    exit
fi


sudo apt-get -y install pdsh
export PDSH_RCMD_TYPE=ssh



repo_name=$1
echo "Syncing Repo ${repo_name}"

src_jobsubplus=/root/code/sherpa/jobSubPub_src/jobSubPlusCounters/
src_tzctcommon=/root/code/sherpa/tzCtCommon/TzCtCommon/
src_tenzing=/root/code/sherpa/tenzing_src/Tenzing/
src_ca=/root/code/sherpa/clientagent_src/ClientAgent/
src_mr=/root/code/sherpa/mr_client_src/hadoop2.7/
src_hive=/root/code/sherpa/hive_client_src/hiveClientSherpa/
src_hdp_hive=/root/code/sherpa/hdp/HDP-hive/
src_hdp_mr=/root/code/sherpa/hdp/HDP-mr-client-2.3.6/



dst_jobsubplus=/root/sherpa/jobSubPub_src/jobSubPlusCounters/
dst_tzctcommon=/root/sherpa/tzCtCommon/TzCtCommon/
dst_tenzing=/root/sherpa/tenzing_src/Tenzing/
dst_ca=/root/sherpa/clientagent_src/ClientAgent/
dst_mr=/root/sherpa/mr_client_src/hadoop2.7/
dst_hive=/root/sherpa/hive_client_src/hiveClientSherpa/
dst_hdp_hive=/root/sherpa/hdp/HDP-hive/
dst_hdp_mr=/root/sherpa/hdp/HDP-mr-client-2.3.6/


pdsh -w ${host}   "mkdir -p ${dst_jobsubplus}"
pdsh -w ${host}   "mkdir -p ${dst_tzctcommon}"
pdsh -w ${host}   "mkdir -p ${dst_tenzing}"
pdsh -w ${host}   "mkdir -p ${dst_ca}"
pdsh -w ${host}   "mkdir -p ${dst_mr}"
pdsh -w ${host}   "mkdir -p ${dst_hive}"
pdsh -w ${host}   "mkdir -p ${dst_hdp_hive}"
pdsh -w ${host}   "mkdir -p ${dst_hdp_mr}"




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
elif [[ "${repo_name}" = "hdp_hive"  ]]; then
    src=${src_hdp_hive}
    dst=${dst_hdp_hive}
elif [[ "${repo_name}" = "hdp_mr"  ]]; then
    src=${src_hdp_mr}
    dst=${dst_hdp_mr}


else
    echo "Error: Repo name not supported ..."
    exit
fi

echo "Host: ${host}"
echo "User: ${user}"
echo "Source: ${src}"
echo "Dst: ${dst}"


rsync -vhrz --progress --delete --exclude 'target/*'  --exclude '*/target' --exclude '*.jar' --exclude '*.war' --exclude '*.class' --exclude '.git/'  ${src}  ${user}@${host}:${dst}
