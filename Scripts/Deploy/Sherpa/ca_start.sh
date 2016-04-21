#!/bin/bash
client_agent_install_dir=/opt/sherpa/ClientAgent/
client_agent_executable_file=ClientAgent-1.0-jar-with-dependencies.jar
nohup java -cp  ${client_agent_install_dir}/${client_agent_executable_file} com.sherpa.clientagent.clientservice.AgentService > ${client_agent_install_dir}/client-agent.log &
