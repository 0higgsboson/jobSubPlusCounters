#!/bin/bash


queue_name=default
dataProfilesList=("10GB")
#tuned_params_file=/root/sherpa/jobSubPub_src/jobSubPlusCounters/Scripts/Deploy/HiBench/tunedparams.json
tuned_params_file=tunedparams.json

reset=no
updateCA=no
updateTenzing=no

costObjectivesList=("Latency")
workloadsList=("join" "aggregation" "scan")




