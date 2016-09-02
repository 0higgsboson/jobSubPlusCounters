#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/configurations.sh
source ${CWD}/workload_configurations.sh
source ${CWD}/utils.sh



export PDSH_RCMD_TYPE=ssh


# Tenzing
print "Updating Tenzing ..."
if [[ "${updateTenzing}" = "yes"  ]];
then
    pdcp -r -w ${tenzing_host}  "tenzing_kill.sh"   "${tenzing_install_dir}/"
    pdsh -w ${tenzing_host} "${tenzing_install_dir}/tenzing_kill.sh"

    pdsh -w    ${tenzing_host} "rm ${tenzing_install_dir}/tunedparams.json"
    pdcp -r -w ${tenzing_host}   "${tuned_params_file}"        "${tenzing_install_dir}/"

    pdsh -w ${tenzing_host} "touch ${tenzing_install_dir}/SherpaSequenceNos.txt"
else
    echo "Skipping Tenzing update ..."
fi

if [[ "${reset}" = "yes"  ]];
then
    print "Reseting Tenzing Db ..."
    pdcp -r -w ${tenzing_host}  "tenzing_kill.sh"   ${tenzing_install_dir}/
    pdsh -w ${tenzing_host} "${tenzing_install_dir}/tenzing_kill.sh"

    pdcp -r -w ${tenzing_host}  "resetDb.js"   ${tenzing_install_dir}/
    pdsh -w ${tenzing_host} "mongo < ${tenzing_install_dir}/resetDb.js"

    pdsh -w ${tenzing_host} "rm ${tenzing_install_dir}/SherpaSequenceNos.txt"
    pdsh -w ${tenzing_host} "touch ${tenzing_install_dir}/SherpaSequenceNos.txt"

    pdcp -r -w ${tenzing_host}   "${tuned_params_file}"        "${tenzing_install_dir}/"
else
    echo "Skipping Tenzing reset ..."
fi


if [[ "${updateTenzing}" = "yes"  || "${reset}" = "yes" ]];
then
      pdsh -w ${tenzing_host}   "nohup java -cp  ${tenzing_install_dir}/${tenzing_executable_file} com.sherpa.tenzing.remoting.TenzingService > ${tenzing_install_dir}/tenzing.log &"
else
    echo "Skipping Tenzing Start ..."
fi




# Client Agent
print "Updating Client Agent ..."
if [[ "${updateCA}" = "yes"  ]];
then
    pdcp -r -w ${clientagent_host}  "ca_kill.sh"   ${clientagent_install_dir}/
    pdsh -w ${clientagent_host} "${clientagent_install_dir}/ca_kill.sh"
    pdsh -w ${clientagent_host} "touch ${clientagent_install_dir}/configs.json"
else
    echo "Skipping Client Agent update ..."
fi

if [[ "${reset}" = "yes"  ]];
then
    print "Reseting ClientAgent Db ..."
    pdcp -r -w ${clientagent_host}  "ca_kill.sh"   ${clientagent_install_dir}/
    pdsh -w ${clientagent_host} "${clientagent_install_dir}/ca_kill.sh"
    pdsh -w ${clientagent_host} "rm ${clientagent_install_dir}/configs.json"
    pdsh -w ${clientagent_host} "touch ${clientagent_install_dir}/configs.json"
else
    echo "Skipping Client Agent reset ..."
fi


if [[ "${updateCA}" = "yes"  || "${reset}" = "yes" ]];
then
    pdsh -w ${clientagent_host}   "nohup java -cp  ${clientagent_install_dir}/${clientagent_executable_file} com.sherpa.clientagent.clientservice.AgentService > ${clientagent_install_dir}/client-agent.log &"

else
    echo "Skipping Client Agent Start ..."
fi



for workload in "${workloadsList[@]}"
do
     for dataProfile in "${dataProfilesList[@]}"
     do
         if [[ "${workload}" = "sort" || "${workload}" = "terasort" || "${workload}" = "wordcount" || "${workload}" = "kmeans" || "${workload}" = "bayes" ]]
         then
              echo "MR workload ..."
             ./MR/mr_generic_prepare.sh $workload  $dataProfile
         elif [[ "${workload}" = "join" || "${workload}" = "scan" || "${workload}" = "aggregation" ]]
         then
             echo "SQL workload ..."
            ./SQL/sql_generic_prepare.sh $workload  $dataProfile
         else
              echo "Possible workload names: ( sort | terasort | wordcount | scan | join | aggregation | kmeans | bayes )"
        fi


        for costObjective in "${costObjectivesList[@]}"
        do


                    iterations=50
                    if [[ "${workload}" = "kmeans" || "${workload}" = "bayes" ]]
                    then
                        iterations=10
                    fi

                    tag=${workload}_${costObjective}_${dataProfile}_${suffix}

                    print ${tag}

                    NOW=$(date +"%Y-%m-%d-%H-%M")
                    tempDir="${tag}-${NOW}"
                    workloadMetaDir="${backup_base_dir}/${tempDir}"
                    mkdir -p "${workloadMetaDir}"

                    echo "Meta Dir: ${workloadMetaDir}"

                   ./run.sh "${workload}" false 1              "${tag}"  "${workloadMetaDir}"  "${costObjective}"  "${queue_name}"
                   ./run.sh "${workload}" true "${iterations}" "${tag}"  "${workloadMetaDir}"  "${costObjective}"  "${queue_name}"

#                    printf "\n Generating Spreadsheet"
#                    cd /root/sherpa/jobSubPub_src/jobSubPlusCounters/reports
#                    java -jar /root/sherpa/jobSubPub_src/jobSubPlusCounters/reports/target/reports-1.0-jar-with-dependencies.jar "${tag}"
#                    cd /root/sherpa/jobSubPub_src/jobSubPlusCounters/Scripts/HiBenchSetupAndTestScripts


                    echo "Meta Data saved at ${workloadMetaDir}"
                    printf "\n\n ********************************************** Done Testing *****************************************************\n"

        #cost objectives
        done
     # data profiles
     done
# workloads
done






