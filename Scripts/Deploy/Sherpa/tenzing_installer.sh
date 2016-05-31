#!/bin/bash

# Installs Tenzing War File in Tomcat Web Container
# Assumes tenzing-services.war, tunedparams.json & sherpa.properties files are present in the current working directory


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
fileExists  "tenzing-services.war"
fileExists  "sherpa.properties"
fileExists  "tunedparams.json"



# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source "${CWD}"/configurations.sh
source "${CWD}"/utils.sh


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


if [ -z ${tenzing_hostname} ]; then
	echo "Error: Please set tenzing.hostname configuration in ${file} file"
    exit
else
    echo "Tenzing Host: ${tenzing_hostname}"
fi


if [ -z ${tenzing_port} ]; then
	echo "Error: Please set tenzing.port configuration in ${file} file"
    exit
else
    echo "Tenzing Port: ${tenzing_port}"
fi


if [ -z ${tenzing_basepath} ]; then
	echo "Error: Please set tenzing.basepath configuration in ${file} file"
    exit
else
    echo "Tenzing Dir: ${tenzing_basepath}"
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
mkdir -p  ${tenzing_basepath}


if [ -f  "${tomcat_home}/webapps/tenzing-services.war" ];
then
    echo "Removing existing services ..."
    rm ${tomcat_home}/webapps/tenzing-services.war
    rm -r ${tomcat_home}/webapps/tenzing-services
fi



echo "Copying files ..."
cp "sherpa.properties"    "/opt/sherpa.properties"
cp "tunedparams.json"  ${tenzing_basepath}/
touch ${tenzing_basepath}/SherpaSequenceNos.txt
cp "tenzing-services.war" ${tomcat_home}/webapps/

echo "Waiting 20 sec for services to get up ..."
sleep 20

echo "URL: http://${tenzing_hostname}:${tenzing_port}/tenzing-services/api/1.0/version/"
response=`curl http://${tenzing_hostname}:${tenzing_port}/tenzing-services/api/1.0/version/`

if [  ${response} == "1.0" ]; then
    echo "Tenzing Started Successfully ..."
else
    echo "Tenzing did not respond, check tomcat logs ..."
fi


echo "Mongo DB Install: ${db_install}"
if [[ "${db_install}" != "yes"  ]];
then
    echo "Install flag is turned off !!!"
    echo "Skipping Mongo DB Installation ..."
else
    echo "Installing Mongo DB ..."
    ./Mongo/db_installer.sh
fi

