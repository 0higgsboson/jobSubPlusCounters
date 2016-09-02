#!/bin/bash
#set -e

TOMCAT_VERSION=8.0.36
HADOOP_VERSION=2.7.1
DATA_PROFILE=small


# configure password-less ssh access to the following hosts
CLIENT_HOSTNAME=SherpaDevVM
CA_HOSTNAME=SherpaDevVM
TENZING_HOSTNAME=SherpaDevVM


client_install_dir=/opt/sherpa/lib
ca_install_dir=/opt/sherpa/ClientAgent
ca_tomcat_dir=/opt/tomcat
tenzing_install_dir=/opt/sherpa/Tenzing
tenzing_tomcat_dir=/opt/tomcat

jobsubplus_src_dir=/root/sherpa/jobSubPub_src/
common_src_dir=/root/sherpa/tzCtCommon/
tenzing_src_dir=/root/sherpa/tenzing_src/
clientagent_src_dir=/root/sherpa/clientagent_src/
mr_client_src_dir=/root/sherpa/mr_client_src/
hive_client_src_dir=/root/sherpa/hive_client_src/



# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`




function installPdshonRemoteHost(){
  # takes hostname as input

  host=$1
  if [ ! -f  "/etc/redhat-release" ];
    then
        pdsh -w ${host}  "apt-get -y install pdsh"
      else
        pdsh -w ${host}  "yum -y install pdsh"
    fi

  pdsh -w ${host} "export PDSH_RCMD_TYPE=ssh"
}


function installPdsOnLocalhost(){
  if [ ! -f  "/etc/redhat-release" ];
    then
        sudo apt-get -y install pdsh
      else
        sudo yum -y install pdsh
    fi
}


installPdsOnLocalhost
export PDSH_RCMD_TYPE=ssh
installPdshonRemoteHost ${CLIENT_HOSTNAME}
installPdshonRemoteHost ${CA_HOSTNAME}
installPdshonRemoteHost ${TENZING_HOSTNAME}




if [[ ${HADOOP_VERSION} == *"2.7"* ]]; then
    MR_SRC_DIR=hadoop2.7
else
    MR_SRC_DIR=mrClient
fi


echo "Updating & Building Code ..."
echo "--------------------------------------------------------------------"
./sherpa_installer.sh package apache 2.7.1 yes
echo  "Done Building Code"
echo ""


echo "Updating Client ...."
echo "--------------------------------------------------------------------"
pdsh -w ${CLIENT_HOSTNAME} "rm -r ${client_install_dir}"
pdsh -w ${CLIENT_HOSTNAME} "mkdir -p ${client_install_dir}"
pdcp -w ${CLIENT_HOSTNAME}  ${common_src_dir}/TzCtCommon/target/TzCtCommon*jar-with-dependencies*.jar   ${client_install_dir}/

if [[ ${HADOOP_VERSION} == *"2.7"* ]]
then
    pdcp -w ${CLIENT_HOSTNAME}  ${mr_client_src_dir}/${MR_SRC_DIR}/target/hadoop-mapreduce-client-core*.jar   ${client_install_dir}/
else
    pdcp -w ${CLIENT_HOSTNAME}  ${mr_client_src_dir}/${MR_SRC_DIR}/target/hadoop-mapreduce-client-core*.jar   ${client_install_dir}/
fi

pdcp -w ${CLIENT_HOSTNAME}  ${hive_client_src_dir}/hiveClientSherpa/cli/target/hive-cli*.jar   ${client_install_dir}/
pdcp -w ${CLIENT_HOSTNAME}  ${hive_client_src_dir}/hiveClientSherpa/ql/target/hive-exec*.jar   ${client_install_dir}/

echo "Done Updating Client..."
echo ""




echo "Updating Tenzing ...."
echo "--------------------------------------------------------------------"
pdsh -w ${TENZING_HOSTNAME} "supervisorctl stop Tomcat"
pdsh -w ${TENZING_HOSTNAME} "rm -rf  ${tenzing_tomcat_dir}/apache-tomcat-${TOMCAT_VERSION}/webapps/tenzing-services*"
pdcp -w ${TENZING_HOSTNAME}  ${tenzing_src_dir}/Tenzing/RestServices/target/tenzing-services*.war   ${tenzing_tomcat_dir}/apache-tomcat-${TOMCAT_VERSION}/webapps/tenzing-services.war
pdsh -w ${TENZING_HOSTNAME} "supervisorctl start Tomcat"

echo "Done Updating Tenzing..."
echo ""




echo "Updating CA ...."
echo "--------------------------------------------------------------------"
pdsh -w ${CA_HOSTNAME} "supervisorctl stop Tomcat"
pdsh -w ${CA_HOSTNAME} "rm -rf  ${ca_tomcat_dir}/apache-tomcat-${TOMCAT_VERSION}/webapps/ca-services*"
pdcp -w ${CA_HOSTNAME}  ${clientagent_src_dir}/ClientAgent/ca-services/target/ca-services*.war   ${ca_tomcat_dir}/apache-tomcat-${TOMCAT_VERSION}/webapps/ca-services.war
pdsh -w ${CA_HOSTNAME} "supervisorctl start Tomcat"

echo "Done Updating CA..."
echo ""


datetime=$(date +"%Y-%m-%d-%H-%M-%S")
#${CWD}/../HiBench/Throughput/hibench_throughput.sh sort       ${DATA_PROFILE} 1 51 ${datetime}
#${CWD}/../HiBench/Throughput/hibench_throughput.sh terasort   ${DATA_PROFILE} 1 51 ${datetime}
#${CWD}/../HiBench/Throughput/hibench_throughput.sh wordcount  ${DATA_PROFILE} 1 51 ${datetime}


