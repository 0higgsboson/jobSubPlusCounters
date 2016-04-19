#!/bin/bash

# Assumptions
# Java 1.7 is installed & available on path


# Client Agent Configurations
#----------------------------------------------------------------------------------------------------------------------

# Write permissions required on following dir
client_agent_install_dir=/opt/sherpa/ClientAgent/
client_agent_property_file=sherpa.properties
client_agent_executable_file=ClientAgent-1.0-jar-with-dependencies.jar
client_agent_kill_script=ca_kill.sh
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


# Make sure required files exist
fileExists  ${client_agent_executable_file}
fileExists  ${client_agent_property_file}
fileExists  ${client_agent_kill_script}

echo "Creating dir structure ..."
mkdir -p  ${client_agent_install_dir}

echo "Copying files ..."
cp   "${client_agent_property_file}"    "/opt/sherpa.properties"
cp   "${client_agent_executable_file}"  "${client_agent_install_dir}/"
cp   "${client_agent_kill_script}"      "${client_agent_install_dir}/"


echo "Killing existing processes ..."
"${client_agent_install_dir}/${client_agent_kill_script}"



echo "Starting Up Client Agent ..."
nohup java -cp  ${client_agent_install_dir}/${client_agent_executable_file} com.sherpa.clientagent.clientservice.AgentService > ${client_agent_install_dir}/client-agent.log &
echo "Client Agent Installed Successfully ..."