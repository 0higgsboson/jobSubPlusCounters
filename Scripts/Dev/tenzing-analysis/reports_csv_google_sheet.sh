#!/bin/bash

file_location="/root/jobSubPlusCounters/Scripts/Deploy/HiBench"

suffix=$(grep "suffix=" ${file_location}/snowflake.sh | awk -F'"' '{print $2}' | awk -F"=" '{print "\""$2"\""}');
sed -i "s/suffix = .*/suffix = ${suffix}/" csv-best-configs5.py

#workloads=$(grep "workloadsList=" workload_configurations_pre.sh | awk -F"=" '{print $2}' | tr "(" "[" | tr ")" "]" | tr " " "," | tr "\t" ",");
workloads=$(grep "workloadsList=" ${file_location}/workload_configurations_pre.sh | awk -F"=" '{print $2}' | sed "s/^( */[/" | sed "s/ *)$/]/" | tr " " "," | tr "\t" "," );
sed -i "s/workloads = .*/workloads = ${workloads}/" csv-best-configs5.py

dataSizes=$(grep "dataProfilesList=" ${file_location}/workload_configurations_pre.sh | awk -F"=" '{print $2}' | sed "s/^( */[/" | sed "s/ *)$/]/" | tr " " "," | tr "\t" ",");
sed -i "s/dataSizes = .*/dataSizes = ${dataSizes}/" csv-best-configs5.py

costObjectives=$(grep "costObjectivesList=" ${file_location}/workload_configurations_pre.sh | awk -F"=" '{print $2}' | sed "s/^( */[/" | sed "s/ *)$/]/" | tr " " ","| tr "\t" ",");
sed -i "s/costObjectives = .*/costObjectives = ${costObjectives}/" csv-best-configs5.py

low_high=$(grep "seq" ${file_location}/snowflake.sh | awk -F'`' '{print $2}');
low=$(echo ${low_high} | awk -F" " '{print $2}');
sed -i "s/low = .*/low = ${low}/" csv-best-configs5.py

high=$(echo ${low_high} | awk -F" " '{print $3}');
sed -i "s/high = .*/high = ${high}/" csv-best-configs5.py

#python csv-best-configs5.py > csv-best-configs5.csv
