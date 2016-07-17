#!/bin/bash

# Note:
# Current client implementation for queue is as follows:
# 1. If queue name other than default is specified use that
# 2. if queue name is not specified, then hadoop sets it to default, or if user sets queue name to default, client has no way to find whether queue was set or not
#    so current implementation tries to find a queue other than (root & default), if found use that, otherwise use default


CA_TOMCAT_HOME=/root/Downloads/ca_tomcat/apache-tomcat-8.0.35/
HADOOP_HOME=/root/cluster/hadoop/hadoop-2.7.2/
HADOOP_VERSION=2.7.2
CA_HOME=/opt/sherpa/ClientAgent/
USER=root
QUEUE=twentyfive
CLUSTER=sherpa

input_path=/tests/in/user_queue_cluster/

# By disabling following lines, input path would not be created & hence jobs wont be launched, which will make tests to finish quickly
#hdfs dfs -mkdir -p ${input_path}
#hdfs dfs -copyFromLocal $0 $(input_path}

output_path=/tests/out/user_queue_cluster/
log_dir=tests
rm -r ${log_dir}
mkdir ${log_dir}
log_file=${log_dir}/user_queue_cluster


conf_dir=${CA_HOME}/conf/
mkdir -p ${conf_dir}

tomcat_shutdown_script=${CA_TOMCAT_HOME}/bin/shutdown.sh
tomcat_startup_script=${CA_TOMCAT_HOME}/bin/startup.sh

sleep_time=60


function removeFile(){
if [[ -f $1 ]]; then
  rm $1
fi

}

function clean(){
  removeFile ${conf_dir}/user.conf
  removeFile ${conf_dir}/queue.conf
  removeFile ${conf_dir}/cluster.conf
  removeFile ${CA_HOME}/ca_configs.json

}



function runTest(){
 # takes PSManaged value as input
 # takes test expected result as input
 psm=$1
 result=$2
 msg=$3
 test_number=$4

  echo "${msg} ${test_number}"
  echo "----------------------------------------------------------------------------------------------------------------------------"

  # Enable following line if actual jobs needs to be run
  #hdfs dfs -rm -r ${output_path}
  yarn jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-examples-${HADOOP_VERSION}.jar wordcount -D PSManaged=${psm}  -D SherpaCostObj=Memory ${input_path} ${output_path} > "${log_file}_${test_number}.log" 2>&1

  #echo "Result: ${result}"
  if cat "${log_file}_${test_number}.log"  | grep -q "Tuned job=${result}"; then
    echo "Test Succeeded ..."
  else
    echo "Test Failed ..."
  fi

  echo ""
  echo ""
}


function runTest2(){
 # takes PSManaged value as input
 # takes test expected result as input
 result=$1
 msg=$2
 test_number=$3

  echo "${msg} ${test_number}"
  echo "----------------------------------------------------------------------------------------------------------------------------"

  # Enable following line if actual jobs needs to be run
  #hdfs dfs -rm -r ${output_path}
  yarn jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-examples-${HADOOP_VERSION}.jar wordcount  -D SherpaCostObj=Memory ${input_path} ${output_path} > "${log_file}_${test_number}.log" 2>&1

  #echo "Result: ${result}"
  if cat "${log_file}_${test_number}.log"  | grep -q "Tuned job=${result}"; then
    echo "Test Succeeded ..."
  else
    echo "Test Failed ..."
  fi

  echo ""
  echo ""
}



function runTest3(){
 # takes PSManaged value as input
 # takes test expected result as input
 result=$1
 msg=$2
 queue_name=$3
 test_number=$4

  echo "${msg} ${test_number}"
  echo "----------------------------------------------------------------------------------------------------------------------------"

  # Enable following line if actual jobs needs to be run
  #hdfs dfs -rm -r ${output_path}
  yarn jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-examples-${HADOOP_VERSION}.jar wordcount -D mapreduce.job.queuename=${queue_name} -D SherpaCostObj=Memory ${input_path} ${output_path} > "${log_file}_${test_number}.log" 2>&1

  #echo "Result: ${result}"
  if cat "${log_file}_${test_number}.log"  | grep -q "Tuned job=${result}"; then
    echo "Test Succeeded ..."
  else
    echo "Test Failed ..."
  fi

  echo ""
  echo ""
}






echo "Testing By Setting PsManaged Argument..."
clean
echo "${USER}=false" > ${conf_dir}/user.conf
runTest "true" "true" "PsManaged=true, user ${USER}=false"    1

clean
echo "${QUEUE}=false" > ${conf_dir}/queue.conf
runTest "true" "true" "PsManaged=true, queue ${QUEUE}=false"  2

clean
echo "${CLUSTER}=false" > ${conf_dir}/cluster.conf
runTest "true" "true" "PsManaged=true, cluster ${CLUSTER}=false" 3



echo "Testing By Not Setting PsManaged & Queue Arguments ..."
clean
echo "${USER}=false" > ${conf_dir}/user.conf
${tomcat_shutdown_script}
${tomcat_startup_script}
sleep ${sleep_time}
runTest2 "false"  "user ${USER}=false"   4

clean
echo "${USER}=true" > ${conf_dir}/user.conf
${tomcat_shutdown_script}
${tomcat_startup_script}
sleep ${sleep_time}
runTest2 "true"  "user ${USER}=true"     5

clean
echo "${QUEUE}=false" > ${conf_dir}/queue.conf
${tomcat_shutdown_script}
${tomcat_startup_script}
sleep ${sleep_time}
runTest2 "false"  "queue ${QUEUE}=false"  6

clean
echo "${QUEUE}=true" > ${conf_dir}/queue.conf
${tomcat_shutdown_script}
${tomcat_startup_script}
sleep ${sleep_time}
runTest2 "true"  "queue ${QUEUE}=true"   7

clean
echo "${CLUSTER}=false" > ${conf_dir}/cluster.conf
${tomcat_shutdown_script}
${tomcat_startup_script}
sleep ${sleep_time}
runTest2 "false"  "cluster ${CLUSTER}=false"  8

clean
echo "${CLUSTER}=true" > ${conf_dir}/cluster.conf
${tomcat_shutdown_script}
${tomcat_startup_script}
sleep ${sleep_time}
runTest2 "true"  "cluster ${CLUSTER}=true"  9



clean
echo "${QUEUE}=false" > ${conf_dir}/queue.conf
${tomcat_shutdown_script}
${tomcat_startup_script}
sleep ${sleep_time}
runTest3 "false"  "queue ${QUEUE}=false" "default" 10



clean
echo "${QUEUE}=true" > ${conf_dir}/queue.conf
${tomcat_shutdown_script}
${tomcat_startup_script}
sleep ${sleep_time}
runTest3 "true"  "queue ${QUEUE}=true" "default" 11


echo "Finished Testing ..."

