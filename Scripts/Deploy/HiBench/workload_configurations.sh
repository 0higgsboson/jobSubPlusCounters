#!/bin/bash

tenzing_host=tenzing
tenzing_port=3052
tenzing_install_dir=/opt/sherpa/Tenzing/

clientagent_host=client-agent
clientagent_port=2552
clientagent_install_dir=/opt/sherpa/ClientAgent/

dataProfile=large
#tuned_params_file=/root/sherpa/jobSubPub_src/jobSubPlusCounters/Scripts/Deploy/HiBench/tunedparams.json
tuned_params_file=/opt/tunedparams.json

reset=no
updateCA=no
updateTenzing=no

suffix=02-04-2016

costObjectivesList=("Memory" "Latency" "CPU")
workloadsList=("sort" "wordcount" "kmeans" "bayes" "scan" "join" "aggregation")