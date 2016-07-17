#!/bin/bash

# Cost objective priority:  1. user provided  2. User   3. queue     4. cluster

CA_TOMCAT_HOME=/opt/tomcat/ca-tomcat/
CA_HOME=/opt/sherpa/ClientAgent/
HADOOP_HOME=/root/cluster/hadoop/hadoop-2.7.1/
HADOOP_VERSION=2.7.1
USER=root
QUEUE=default
CLUSTER=sherpa


input_path=/tests/in/user_queue_cluster/

# By disabling following lines, input path would not be created & hence jobs wont be launched, which will make tests to finish quickly
#hdfs dfs -mkdir -p ${input_path}
#hdfs dfs -copyFromLocal $0 $(input_path}

output_path=/tests/out/user_queue_cluster/
log_dir=cost_objective_tests
rm -r ${log_dir}
mkdir ${log_dir}
log_file=${log_dir}/user_queue_cluster_cost_objective


conf_dir=${CA_HOME}/conf/
mkdir -p ${conf_dir}

tomcat_shutdown_script=${CA_TOMCAT_HOME}/bin/shutdown.sh
tomcat_startup_script=${CA_TOMCAT_HOME}/bin/startup.sh

sleep_time=20


function removeFile(){
if [[ -f $1 ]]; then
  rm $1
fi

}

function clean(){
  removeFile ${conf_dir}/user_co.conf
  removeFile ${conf_dir}/queue_co.conf
  removeFile ${conf_dir}/cluster_co.conf
  removeFile ${CA_HOME}/ca_configs.json
}



function runWithCostObjective(){
 # takes Cost Objective value as input
 cost_obj=$1
 msg=$2
 test_number=$3

  echo "${msg} ${test_number}"
  echo "----------------------------------------------------------------------------------------------------------------------------"

  # Enable following line if actual jobs needs to be run
  #hdfs dfs -rm -r ${output_path}
  yarn jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-examples-${HADOOP_VERSION}.jar wordcount -D PSManaged=true  -D SherpaCostObj=${cost_obj} ${input_path} ${output_path} > "${log_file}_${test_number}.log" 2>&1

  #echo "Result: ${result}"
  if cat "${log_file}_${test_number}.log"  | grep -q "Cost Objective: ${cost_obj}"; then
    echo "Test Succeeded ..."
  else
    echo "Test Failed ..."
  fi

  echo ""
  echo ""
}


function runWithoutCostObjective(){
 # takes Cost Objective value as input
 cost_obj=$1
 msg=$2
 test_number=$3

  echo "${msg} ${test_number}"
  echo "----------------------------------------------------------------------------------------------------------------------------"

  # Enable following line if actual jobs needs to be run
  #hdfs dfs -rm -r ${output_path}
  yarn jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-examples-${HADOOP_VERSION}.jar wordcount -D PSManaged=true  ${input_path} ${output_path} > "${log_file}_${test_number}.log" 2>&1

  #echo "Result: ${result}"
  if cat "${log_file}_${test_number}.log"  | grep -q "Cost Objective: ${cost_obj}"; then
    echo "Test Succeeded ..."
  else
    echo "Test Failed ..."
  fi

  echo ""
  echo ""

}


function restartTomcat(){
    ${tomcat_shutdown_script}
    ${tomcat_startup_script}
    sleep ${sleep_time}
}





# Test Case 1
echo "Testing By Setting Cost Objective Argument..."
clean
echo "${USER}=Memory" > ${conf_dir}/user_co.conf
restartTomcat
runWithCostObjective "Latency"  "SherpaCostObj=Latency"    1

clean
echo "${QUEUE}=Memory" > ${conf_dir}/queue_co.conf
restartTomcat
runWithCostObjective "Latency"  "SherpaCostObj=Latency"    2

clean
echo "${CLUSTER}=Memory" > ${conf_dir}/cluster_co.conf
restartTomcat
runWithCostObjective "Latency"  "SherpaCostObj=Latency"    3





# Test Case 2
echo "Testing By Not Setting Cost Objective ..."
clean
echo "${USER}=Latency" > ${conf_dir}/user_co.conf
restartTomcat
runWithoutCostObjective "Latency"  "User ${USER}=Latency"    4


clean
echo "${QUEUE}=Latency" > ${conf_dir}/queue_co.conf
restartTomcat
runWithoutCostObjective "Latency"  "Queue ${QUEUE}=Latency"    5



clean
echo "${CLUSTER}=Latency" > ${conf_dir}/cluster_co.conf
restartTomcat
runWithoutCostObjective "Latency"  "Cluster ${CLUSTER}=Latency"    6




echo "Finished Testing ..."

