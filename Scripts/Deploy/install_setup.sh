#!/bin/bash

# Assumptions
# 1. Use root account
# 2. First node of hosts file will be treated as master node
# 3. Public/Private keys should already be set up

if [ "$#" -ne 2 ]; then
    echo "Usage: ./install_setup.sh authenticate_key etc_hosts tenzing_package.tar.gz"
    exit
fi

#set -e
source configuration.sh

# Save Script Working Dir
CWD=`dirname "$0"`
pwd=`cd "$CWD"; pwd`

key=$1
etc_hosts=$2
tenzing_tar=$3
hostsFile="hosts_file"

cat etc_hosts | awk -F" " '{print $3}' > ${hostsFile}

master_node=$(cat ${hostsFile} | head -1)

#Generate RSA key on master node
ssh-keygen -t rsa -P ""
echo "Generated RSA key on master node"

#Copy the pub key to all slave nodes
#ssh-copy-id -i ~/.ssh/id_rsa.pub 35.166.143.104
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#cat ${public_ips} | sed -e 1d

for host in $(cat ${hostsFile} | sed -e 1d);do ssh -ti ${key} ${username}@${host} 'sudo cp ~/.ssh/authorized_keys /root/.ssh/';done

for host in $(cat ${hostsFile} | sed -e 1d);do cat ~/.ssh/id_rsa.pub | ssh -ti ${key} ${host} 'cat >> /root/.ssh/authorized_keys';done

cat ${etc_hosts} >> /etc/hosts
for host in $(cat ${hostsFile} | sed -e 1d);do cat ${etc_hosts} | ssh -ti ${key} ${host} 'cat >> /etc/hosts';done

#Verify the ssh connection with hostname
for host in $(cat ${hostsFile});do ssh $host 'echo "Connected to "`hostname`';done

echo "Done passwordless authentication and set the hosts file"

#hostsFile=$1
#hostsFile=`readlink -f $1`

cd ${SCRIPTS_DIR}/Cluster && ./install_all.sh ${pwd}/${hostsFile}
#echo "cd ${pwd}/Cluster && ./install-all.sh ${pwd}/${hostsFile}"
status_hadoop=$?
if [ ${status_hadoop} -eq 0 ]
then
   # Execute "source /etc/environment" on all nodes
   source /etc/environment
   pdsh -R ssh -w ^${hostsFile} "source /etc/environment"
   #echo "Success"
   
   #Create sherpa/tenzing packages
   cd ${SCRIPTS_DIR}/Sherpa && ./sherpa_installer.sh package ${DISTRO_NAME} [${HADOOP_VERSION}]
   #echo "cd ${pwd}/Sherpa && ./sherpa_installer package ${DISTRO_NAME} [${HADOOP_VERSION}]"
   cd ${PACKAGE_DIR}
   tar -xzvf sherpa.tar.gz
   cd ${PACKAGE_DIR}/sherpa
   #ls
   ./installer.sh
   echo 'export HADOOP_USER_CLASSPATH_FIRST=true' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
   echo 'export HADOOP_CLASSPATH=/opt/sherpa/lib/*:$HADOOP_CLASSPATH' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
   pdsh -R ssh -w ${ca_host} "mkdir -p ${PACKAGE_DIR}"
   scp ${PACKAGE_DIR}/sherpa.tar.gz ${ca_host}:${PACKAGE_DIR}/.
   pdsh -R ssh -w ${ca_host} "cd ${PACKAGE_DIR} && tar -xzvf sherpa.tar.gz"
   pdsh -R ssh -w ${ca_host} "cd ${PACKAGE_DIR}/sherpa && ./tomcat_setup.sh CA"
   pdsh -R ssh -w ${ca_host} "cd ${PACKAGE_DIR}/sherpa && ./client_agent_installer.sh"

   #Creating tenzing package
   #cd ${SCRIPTS_DIR}/Sherpa && ./sherpa_installer tenzing [${HADOOP_VERSION}] 
   # echo "cd ${SCRIPTS_DIR}/Sherpa && ./sherpa_installer tenzing [${HADOOP_VERSION}]"
   pdsh -R ssh -w ${tz_host} "mkdir -p ${PACKAGE_DIR}"
   #scp /root/tenzing-10-29-16.tar.gz ${tz_host}:${PACKAGE_DIR}/.
   scp ${tenzing_tar} ${tz_host}:${PACKAGE_DIR}/.
   pdsh -R ssh -w ${tz_host} "cd ${PACKAGE_DIR} && tar -xzvf tenzing-10-29-16.tar.gz"
   scp ${SCRIPTS_DIR}/Sherpa/sherpa.properties ${tz_host}:${PACKAGE_DIR}/tenzing/.
   pdsh -R ssh -w ${tz_host} "cd ${PACKAGE_DIR}/tenzing && ./tomcat_setup.sh Tenzing"
   echo "Tomcat installed on tenzing server"
   pdsh -R ssh -w ${tz_host} "cd ${PACKAGE_DIR}/tenzing && sed -i 's/INSTALL_DB=no/INSTALL_DB=yes/' tenzing_installer.sh && ./tenzing_installer.sh"
   echo "Tenzing installed on tenzing server"
   pdsh -R ssh -w ${tz_host} "sed -i \"s/host:             process.env.VCAP_APP_HOST                 || 'localhost'/host:             process.env.VCAP_APP_HOST                 || 'hostname'/\" /usr/lib/node_modules/mongo-express/config.js && sudo service mongod restart"

   #Installation of HiBench
   cd ${SCRIPTS_DIR}/HiBench && ./multinode_installer.sh ${pwd}/${hostsFile}
   echo "Installed HiBech"

else
   cd /root/scripts && ./hadoop_stop.sh
   rm -rf /root/cluster && rm -rf /root/scripts
   echo "Your hadoop installation is failed. Please check the hadoop configuration files in ${SCRIPTS_DIR}/Cluster and re-run."
fi
