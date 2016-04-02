#!/bin/bash

tenzing_host=tw1
tenzing_port=3052
tenzing_install_dir=/opt/sherpa/Tenzing/

clientagent_host=tw2
clientagent_port=2552
clientagent_install_dir=/opt/sherpa/ClientAgent/


dataProfile=tiny
tuned_params_file=/root/sherpa/jobSubPub_src/jobSubPlusCounters/Scripts/Deploy/HiBench/tunedparams.json

reset=no
tag=02-04-2016

costObjectivesList=("Memory" "Latency" "CPU")
workloadsList=("sort" "wordcount" "kmeans" "bayes" "scan" "join" "aggregation")