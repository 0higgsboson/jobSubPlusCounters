#!/bin/bash

# Assumptions
# SSH keys should be set up already
# Java 1.7 is installed & available on path


# Client Agent Configurations
#----------------------------------------------------------------------------------------------------------------------
# hostname where to install client agent, password-less ssh access is required
client_agent_host=test-w2
client_agent_install_dir=/opt/sherpa/ClientAgent/
client_agent_property_file=sherpa.properties
client_agent_executable_file=ClientAgent-1.0-jar-with-dependencies.jar
#----------------------------------------------------------------------------------------------------------------------


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


function installPdsh(){
  # takes host as input
  # $1 is host name
  host=$1

  # Setting up pdsh utility
  sudo apt-get -y install pdsh
  export PDSH_RCMD_TYPE=ssh

  pdsh -w ${host}   "apt-get -y install pdsh"
  pdsh -w ${host}   "export PDSH_RCMD_TYPE=ssh"

}

# Make sure required files exist
fileExists  ${client_agent_executable_file}
fileExists  ${client_agent_property_file}

# Install PDSH both locally and on Client Agent machine
installPdsh ${client_agent_host}


echo "Creating dir structure ..."
pdsh -w ${client_agent_host}   "mkdir -p  ${client_agent_install_dir}"

echo "Copying files to ${client_agent_host} ..."
pdcp -r -w ${client_agent_host}   "${client_agent_property_file}"    "/opt/sherpa.properties"
pdcp -r -w ${client_agent_host}   "${client_agent_executable_file}"  "${client_agent_install_dir}/"

echo "Killing existing processes ..."
pdcp -r -w ${client_agent_host}  "ca_kill.sh"   "${client_agent_install_dir}/"
pdsh -w    ${client_agent_host}   "${client_agent_install_dir}/ca_kill.sh"



echo "Starting Up Client Agent ..."
pdsh -w ${client_agent_host}   "nohup java -cp  ${client_agent_install_dir}/${client_agent_executable_file} com.sherpa.clientagent.clientservice.AgentService > ${client_agent_install_dir}/client-agent.log &"

echo "Client Agent Installed Successfully ..."