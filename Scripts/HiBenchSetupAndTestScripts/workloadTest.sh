#!/bin/bash

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source ${CWD}/configurations.sh
source ${CWD}/utils.sh

costObjectivesList=("Memory" "Latency" "CPU")
#workloadsList=("sort" "wordcount" "kmeans" "bayes" "scan" "join" "aggregation")
workloadsList=("sort" "wordcount" "aggregation")
dataProfilesList=("small")
candidateSolutionsList=("8")
learningWeightsList=("0.2")
prefix="2016-01-13"



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

                    createLearningConfigurations2 "$costObjective" "$candidateSolution" "$learingWeightsStr" "$tag"

                    ./iterativeRun.sh "${workload}" false 1 "${tag}"
                    ./iterativeRun.sh "${workload}" true "${iterations}" "${tag}"


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






