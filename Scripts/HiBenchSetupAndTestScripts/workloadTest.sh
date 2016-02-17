#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/configurations.sh
source ${CWD}/utils.sh

#costObjectivesList=("Memory" "Latency" "CPU")
costObjectivesList=("Memory" "Latency")
#workloadsList=("sort" "wordcount" "kmeans" "bayes" "scan" "join" "aggregation")
workloadsList=("terasort")
dataProfilesList=("gigantic")
# dataProfilesList=("tiny")
candidateSolutionsList=("4")
learningWeightsList=("0.2")
prefix="2016-02-16-3"


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

            for candidateSolution in "${candidateSolutionsList[@]}"
            do

                 for learningWeight in "${learningWeightsList[@]}"
                 do

                    iterations=50
                    if [[ "${workload}" = "kmeans" || "${workload}" = "bayes" ]]
                    then
                        iterations=10
                    fi

                    #iterations=$[$iterations*$candidateSolution]

                    tag="${prefix}_${workload}_${costObjective}_${dataProfile}_CS${candidateSolution}_LW${learningWeight}"
                    print ${tag}

                    # sets learningWeightsStr variable
                    getLearningWeights "$candidateSolution" "$learningWeight"
                    #echo "$learingWeightsStr"

                    # sets workloadMetaDir
                    initConfigurations "$costObjective" "$candidateSolution" "$learingWeightsStr" "$tag"
                    echo "Meta Dir: ${workloadMetaDir}"

                   ./run.sh "${workload}" false 1 "${tag}"  "${workloadMetaDir}"
                   ./run.sh "${workload}" true "${iterations}" "${tag}" "${workloadMetaDir}"

                    printf "\n Generating Spreadsheet"
                    cd /root/sherpa/jobSubPub_src/jobSubPlusCounters/reports
                    java -jar /root/sherpa/jobSubPub_src/jobSubPlusCounters/reports/target/reports-1.0-jar-with-dependencies.jar "${tag}"
                    cd /root/sherpa/jobSubPub_src/jobSubPlusCounters/Scripts/HiBenchSetupAndTestScripts

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






