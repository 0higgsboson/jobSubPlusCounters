#!/bin/bash

# Assumptions
# SSH keys should be set up already

set -e

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source "${CWD}"/configurations.sh
source "${CWD}"/utils.sh


if [ -z ${client_agent_install} ]; then
	echo "Please set client_agent_install variable"
    exit
fi

if [[ "$client_agent_install" != "yes"  ]];
then
    print "Install flag is turned off !!!"
    echo "Skipping ..."
    exit
fi

if [ -z ${client_agent_host} ]; then
	echo "Please set client_agent_host variable"
        exit
fi

if [ ! -f  "${client_agent_executable_file}" ];
then
   echo "Error: file ${client_agent_executable_file} does not exist."
   exit
fi


installPdshSingleNode ${client_agent_host}
installJava ${client_agent_host}

print "Creating dir structure"
pdsh -w ${client_agent_host}   "mkdir -p  ${client_agent_install_dir}"

print "Copying files to ${client_agent_host}"
#pdcp -r -w ${client_agent_host}   "${client_agent_property_file}"    "${client_agent_install_dir}/"

# Path is hard coded from where Tenzing reads its configs, copying to that fixed path
pdcp -r -w ${client_agent_host}   "${client_agent_property_file}"    "/opt/sherpa.properties"
pdcp -r -w ${client_agent_host}   "${client_agent_executable_file}"  "${client_agent_install_dir}/"

print "Killing existing processes ..."
pdcp -r -w ${client_agent_host}  "ca_kill.sh"   "${client_agent_install_dir}/"
pdsh -w    ${client_agent_host}   "${client_agent_install_dir}/ca_kill.sh"



print "Starting Up Client Agent ..."
#pdsh -w ${client_agent_host}   "nohup java -jar  ${client_agent_install_dir}/TzCtCommon-1.0-jar-with-dependencies.jar > ${client_agent_install_dir}/client-agent.log &"

pdsh -w ${client_agent_host}   "nohup java -cp  ${client_agent_install_dir}/${client_agent_executable_file} com.sherpa.clientagent.clientservice.AgentService > ${client_agent_install_dir}/client-agent.log &"




pdsh -w ${client_agent_host}   "netstat -anp | grep 2552"

echo "Client Agent Installed Successfully ..."