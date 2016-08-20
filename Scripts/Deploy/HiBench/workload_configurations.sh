#!/bin/bash

tenzing_host=ip-172-31-5-67
tenzing_port=80
tenzing_install_dir=/opt/sherpa/Tenzing/

clientagent_host=ip-172-31-5-68
clientagent_port=80
clientagent_install_dir=/opt/sherpa/ClientAgent/

queue_name=default
dataProfilesList=("tiny" "small" "large")
#tuned_params_file=/root/sherpa/jobSubPub_src/jobSubPlusCounters/Scripts/Deploy/HiBench/tunedparams.json
tuned_params_file=tunedparams.json

reset=no
updateCA=no
updateTenzing=no

suffix=08-19-2016

costObjectivesList=("Memory")
#workloadsList=("sort" "wordcount" "kmeans" "bayes" "scan" "join" "aggregation")
workloadsList=("terasort" "wordcount" "sort" "aggregation" "join")




# Set executable file names for Tenzing & CA installed on Tenzing & CA machines,  executable files not required locally 
tenzing_executable_file=Tenzing-1.0-jar-with-dependencies.jar
clientagent_executable_file=ClientAgent-1.0-jar-with-dependencies.jar
