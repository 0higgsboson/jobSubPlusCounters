#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/configurations.sh
source ${CWD}/workload_test_configurations.sh
source ${CWD}/utils.sh



for workload in "${workloadsList[@]}"
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

                    print ${tag}

                    NOW=$(date +"%Y-%m-%d-%H-%M")
                    tempDir="${tag}-${NOW}"
                    workloadMetaDir="${backup_base_dir}/${tempDir}"
                    mkdir -p "${workloadMetaDir}"

                    export PDSH_RCMD_TYPE=ssh

                    print "Resetting Tenzing ..."
                    pdcp -r -w ${tenzing_host}  "kill.sh"   ${tenzing_install_dir}/
                    pdsh -w ${tenzing_host} "rm ${tenzing_install_dir}/tunedparams.json"
                    pdcp -r -w ${tenzing_host}  "${tuned_params_file}"   ${tenzing_install_dir}/
                    pdsh -w ${tenzing_host} "${tenzing_install_dir}/kill.sh"
                    pdsh -w ${tenzing_host} "touch ${tenzing_install_dir}/SherpaSequenceNos.txt"
                    if [[ "${reset}" = "yes"  ]];
                    then
                        print "Reseting Tenzing Db ..."
                        pdcp -r -w ${tenzing_host}  "resetDb.js"   ${tenzing_install_dir}/
                        pdsh -w ${tenzing_host} "mongo < ${tenzing_install_dir}/resetDb.js"
                        pdsh -w ${tenzing_host} "rm ${tenzing_install_dir}/SherpaSequenceNos.txt"
                        pdsh -w ${tenzing_host} "touch ${tenzing_install_dir}/SherpaSequenceNos.txt"
                    fi
                    pdsh -w ${tenzing_host}   "nohup java -jar  ${tenzing_install_dir}/TzCtCommon-1.0-jar-with-dependencies.jar Tenzing > ${tenzing_install_dir}/tenzing.log &"



                    print "Resetting Client Agent ..."
                    pdcp -r -w ${clientagent_host}  "kill.sh"   ${clientagent_install_dir}/
                    pdsh -w ${clientagent_host} "${clientagent_install_dir}/kill.sh"
                    pdsh -w ${clientagent_host} "touch ${clientagent_install_dir}/configs.json"
                    if [[ "${reset}" = "yes"  ]];
                    then
                        print "Reseting ClientAgent Db ..."
                        pdsh -w ${clientagent_host} "rm ${clientagent_install_dir}/configs.json"
                        pdsh -w ${clientagent_host} "touch ${clientagent_install_dir}/configs.json"

                    fi
                    pdsh -w ${clientagent_host}   "nohup java -jar  ${clientagent_install_dir}/TzCtCommon-1.0-jar-with-dependencies.jar  > ${clientagent_install_dir}/client-agent.log &"




                    echo "Meta Dir: ${workloadMetaDir}"

                   ./run.sh "${workload}" false 1              "${tag}"  "${workloadMetaDir}"  "${costObjective}"
                   ./run.sh "${workload}" true "${iterations}" "${tag}"  "${workloadMetaDir}"  "${costObjective}"

#                    printf "\n Generating Spreadsheet"
#                    cd /root/sherpa/jobSubPub_src/jobSubPlusCounters/reports
#                    java -jar /root/sherpa/jobSubPub_src/jobSubPlusCounters/reports/target/reports-1.0-jar-with-dependencies.jar "${tag}"
#                    cd /root/sherpa/jobSubPub_src/jobSubPlusCounters/Scripts/HiBenchSetupAndTestScripts

                    printf "\nFinished with run, copying meta data ...\n"
                    cp -r /opt/sherpa/* "${workloadMetaDir}/"
                    echo "Meta Data saved at ${workloadMetaDir}"
                    printf "\n\n ********************************************** Done Testing *****************************************************\n"

                  #Learning Weights
                 done

            # Candidate Solutions
            done

        #cost objectives
        done

    # Data Profiles
    done

# workloads
done






