#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/configurations.sh
source ${CWD}/workload_configurations.sh
source ${CWD}/utils.sh
source ${CWD}/mail_info.sh





for workload in "${workloadsList[@]}"
do
    Workload=`echo ${workload} | sed  's/^\(.\)/\U\1/'`
    echo $workload   $Workload
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
	hadoop fs -rm -r /HiBench/${Workload}/Input_${dataProfile}
	hadoop fs -cp -f /HiBench/${Workload}/Input /HiBench/${Workload}/Input_${dataProfile}
    done


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
		    for i in `seq 1 ${iterations}`
		    do
			echo "iteration " ${i} 
			index=$(( ${i} % ${#dataProfilesList[@]} ))
			dp=${dataProfilesList[ $index  ]}
			echo "data size = " $dp
			hadoop fs -rm -r /HiBench/${Workload}/Input
			hadoop fs -cp -f /HiBench/${Workload}/Input_${dp} /HiBench/${Workload}/Input
			./run.sh "${workload}" true 1 "${tag}"  "${workloadMetaDir}"  "${costObjective}"  "${queue_name}"
		    done
#                    printf "\n Generating Spreadsheet"
#                    cd /root/sherpa/jobSubPub_src/jobSubPlusCounters/reports
#                    java -jar /root/sherpa/jobSubPub_src/jobSubPlusCounters/reports/target/reports-1.0-jar-with-dependencies.jar "${tag}"
#                    cd /root/sherpa/jobSubPub_src/jobSubPlusCounters/Scripts/HiBenchSetupAndTestScripts


                    echo "Meta Data saved at ${workloadMetaDir}"
                    printf "\n\n ********************************************** Done Testing *****************************************************\n"

                    /usr/bin/mail -r "${sender}" -a "${contentType}" -s "Snowflake test completed for ${workload}" "${receiver}" <<EOF
Hi Ismail,<br><br>
The following snowflake test is completed.<br>
Workload = ${workload}<br>
Costobjective = ${costObjective}<br>
Data Profile = ${dataProfile}<br>
Tag = ${tag}<br>
<br><br>
Thanks,<br>
Chinna.<br>
EOF

        #cost objectives
        done
     # data profiles
     done
# workloads
done






