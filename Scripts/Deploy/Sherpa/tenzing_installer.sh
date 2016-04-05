#!/bin/bash

# Assumptions
# SSH keys should be set up already

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source "${CWD}"/configurations.sh
source "${CWD}"/utils.sh


if [ -z ${tenzing_install} ]; then
	echo "Please set tenzing_install variable"
    exit
fi

if [[ "$tenzing_install" != "yes"  ]];
then
    print "Install flag is turned off !!!"
    echo "Skipping ..."
    exit
fi

if [ -z ${tenzing_host} ]; then
	echo "Please set tenzing_host variable"
    exit
fi

if [ ! -f  "${tenzing_executable_file}" ];
then
   echo "Error: file ${tenzing_executable_file} does not exist."
   exit
fi


installPdshSingleNode ${tenzing_host}
installJava ${tenzing_host}

print "Creating dir structure"
pdsh -w ${tenzing_host}   "mkdir -p  ${tenzing_install_dir}"

print "Copying files to ${tenzing_host}"
#pdcp -r -w ${tenzing_host}   "${tenzing_property_file}"    "${tenzing_install_dir}/"

pdcp -r -w ${tenzing_host}   "${tenzing_property_file}"    "/opt/sherpa.properties"
pdcp -r -w ${tenzing_host}   "${tenzing_executable_file}"  "${tenzing_install_dir}/"
pdcp -r -w ${tenzing_host}   "${tuned_params_file}"        "${tenzing_install_dir}/"

print "Killing existing processes ..."
pdcp -r -w ${tenzing_host}  "kill.sh"   "${tenzing_install_dir}/"
pdsh -w    ${tenzing_host}   "${tenzing_install_dir}/kill.sh"


print "Starting Up Tenzing ..."
#pdsh -w ${tenzing_host}   "nohup java -jar  ${tenzing_install_dir}/TzCtCommon-1.0-jar-with-dependencies.jar Tenzing > ${tenzing_install_dir}/tenzing.log &"
#pdsh -w ${tenzing_host}   "nohup java -jar  ${tenzing_install_dir}/TzCtCommon-1.0-jar-with-dependencies.jar Db > ${tenzing_install_dir}/db.log &"

pdsh -w ${tenzing_host}   "nohup java -cp  ${tenzing_install_dir}/TzCtCommon-1.0-jar-with-dependencies.jar com.sherpa.common.tzctprotocol.agent.clientservice.AgentService Tenzing > ${tenzing_install_dir}/tenzing.log &"
pdsh -w ${tenzing_host}   "nohup java -cp  ${tenzing_install_dir}/TzCtCommon-1.0-jar-with-dependencies.jar com.sherpa.common.tzctprotocol.agent.clientservice.AgentService Db > ${tenzing_install_dir}/db.log &"






pdsh -w ${tenzing_host}   "netstat -anp | grep 3052"

echo "Tenzing Installed Successfully ..."