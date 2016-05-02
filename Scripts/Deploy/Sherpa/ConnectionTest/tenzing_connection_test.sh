#!/bin/bash


#
# This script should be run on CA machine
# It tests connectivity between CA & Tenzing
#



file="/opt/sherpa.properties"
GIT_SERVER=130.211.164.139



echo "Checking Configuration File ..."
echo "------------------------------------------------------------------------"
if [ -f "$file" ]
then
  while IFS='=' read -r key value
  do
    key=$(echo $key | tr '.' '_')
    eval "${key}='${value}'"
  done < "$file"
else
  echo "$file not found."
  echo "Error: Please install sherpa configuration file ..."
  exit
fi
echo "Configuration file exists ..."
printf "\n\n"





echo "Checking Connection Configurations ..."
echo "------------------------------------------------------------------------"
host=${tenzing_hostname}
port=${tenzing_port}

if [ -z ${host} ]; then
	echo "Error: Please set tenzing.hostname configuration in ${file} file"
    exit
else
    echo "Host: ${host}"
fi

if [ -z ${port} ]; then
	echo "Info: tenzing.port configuration not found in ${file} file, using default port 80"
	port=80
else
    echo "Port: ${port}"
fi

echo "Connection String: ${host}:${port}"
printf "\n\n"





echo "Checking Tenzing Port Connection ..."
echo "------------------------------------------------------------------------"
#apt-get -y install netcat
echo "Connecting to Tenzing at ${host}:${port} ..."
log="$(nc -zv ${host} ${port}  2>&1)"

if [[ $log =~ .*failed.* ]]
then
    echo "Error: Failed to connect to Tenzing At ${host}:${port} ..."
    echo "Here are few troubleshooting steps:"
    echo "1. Make sure Tenzing host and port configurations are correct"
    echo "2. Make sure Tenzing is running and listening at ${host}:${port}"
    echo "3. Make sure firewall allows outbound connection to port ${port}"
    exit
elif [[ $log =~ .*succeeded.* ]]
then
    echo "Tenzing service running at ${host}:${port} ..."
else
    echo "Connection to Tenzing At ${host}:${port} did not work ..."
fi
printf "\n\n"





apt-get install git
echo "Checking Service Handler Connection ..."
echo "------------------------------------------------------------------------"
if [ ! -f  "connectiontest/TzCtCommon-1.0-jar-with-dependencies.jar" ];
then
    echo "Info: Executable file connectiontest/TzCtCommon-1.0-jar-with-dependencies.jar does not exist."
    echo "Downloading jar for hanlder connection test ..."
    git clone git://${GIT_SERVER}/connectiontest.git
fi

java -cp connectiontest/TzCtCommon-1.0-jar-with-dependencies.jar  com.sherpa.common.clients.connectiontest.ConnectionTestSystem Tenzing ${host} ${port}

