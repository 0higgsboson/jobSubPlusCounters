#!/bin/bash

# Installs Client Agent War File in Tomcat Web Container
# Assumes ca-services.war & sherpa.properties files are present in the current working directory


#
# Checks file exists, exits script on file not found
# Takes file path as argument
#
function fileExists(){
    file=$1
    if [ ! -f  "${file}" ];
    then
        echo "Error: file ${file} does not exist."
        exit
    fi
}


# Make sure required files exist
#fileExists  "ca-services*.war"
fileExists  "sherpa.properties"



file="sherpa.properties"

echo "Reading Configuration File ..."
if [ -f "$file" ]
then
  while IFS='=' read -r key value
  do
    key=$(echo $key | tr '.' '_')
    eval "${key}='${value}'"
  done < "$file"
else
  echo "$file not found."
  echo "Error: Sherpa configuration file is missing ..."
  exit
fi


if [ -z ${client_agent_hostname} ]; then
	echo "Error: Please set client.agent.hostname configuration in ${file} file"
    exit
else
    echo "Client Agent Host: ${client_agent_hostname}"
fi





if [ -z ${clientagent_port} ]; then
	echo "Error: Please set clientagent.port configuration in ${file} file"
    exit
else
    echo "Client Agent Port: ${clientagent_port}"
fi


if [ -z ${clientagent_basepath} ]; then
	echo "Error: Please set clientagent.basepath configuration in ${file} file"
    exit
else
    echo "Client Agent Dir: ${clientagent_basepath}"
fi


if [ -z ${tomcat_install_dir} ]; then
	echo "Error: Please set tomcat.install.dir configuration in ${file} file"
    exit
else
    echo "Tomcat Install Dir: ${tomcat_install_dir}"
fi


if [ -z ${tomcat_version} ]; then
	echo "Error: Please set tomcat.version configuration in ${file} file"
    exit
else
    echo "Tomcat Version: ${tomcat_version}"
fi


tomcat_home=${tomcat_install_dir}/apache-tomcat-${tomcat_version}/


echo "Creating dir structure ..."
mkdir -p  ${clientagent_basepath}


if [ -f  "${tomcat_home}/webapps/ca-services.war" ];
then
    echo "Removing existing services ..."
    rm ${tomcat_home}/webapps/ca-services.war
    rm -r ${tomcat_home}/webapps/ca-services
fi



echo "Copying files ..."
cp "sherpa.properties"    "/opt/sherpa.properties"
cp "ca-services*.war" ${tomcat_home}/webapps/ca-services.war

echo "Waiting 20 sec for services to get up ..."
sleep 20


response=`curl http://${client_agent_hostname}:${clientagent_port}/ca-services/api/1.0/version/`
if [  ${response} == "1.0" ]; then
    echo "Client Agent Started Successfully ..."
else
    echo "Client Agent did not respond, check tomcat logs ..."
fi

