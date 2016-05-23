#!/bin/bash

# Assumptions
# SSH keys should be set up already

#set -e

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
#pdcp -r -w ${tenzing_host}   "${tenzing_property_file}"    "/opt/sherpa.properties"
pdsh    -w ${tenzing_host}   "touch ${tenzing_install_dir}/SherpaSequenceNos.txt"

pdcp -r -w ${tenzing_host}   "${db_install_file}"          "${tenzing_install_dir}/"
pdcp -r -w ${tenzing_host}   "supervisor_setup.sh"          "${tenzing_install_dir}/"



print "Killing existing processes ..."
pdcp -r -w ${tenzing_host}  "tenzing_kill.sh"   "${tenzing_install_dir}/"
pdsh -w    ${tenzing_host}   "${tenzing_install_dir}/tenzing_kill.sh"


print "Mongo DB Install:"
if [[ "$db_install" != "yes"  ]];
then
    echo "Install flag is turned off !!!"
    echo "Skipping Mongo DB Installation ..."
else
    echo "Installing Mongo DB ..."
    pdsh -w    ${tenzing_host}   "${tenzing_install_dir}/${db_install_file}"
fi


print "Starting Up Tenzing ..."


if [[ "${SUPERVISE_PROCESS}" = "yes"  ]];
then

    pdsh -w    ${tenzing_host}   "rm ${tenzing_install_dir}/tenzing_start.sh"
    pdsh -w    ${tenzing_host}   "echo \"#!/bin/bash\" >> ${tenzing_install_dir}/tenzing_start.sh"
    pdsh -w    ${tenzing_host}   "echo \"java -cp  ${tenzing_install_dir}/${tenzing_executable_file} com.sherpa.tenzing.remoting.TenzingService\"    >> ${tenzing_install_dir}/tenzing_start.sh"
    pdsh -w    ${tenzing_host}   "echo \"java -cp  ${tenzing_install_dir}/${tenzing_executable_file} com.sherpa.tenzing.remoting.TenzingService Db\" >> ${tenzing_install_dir}/tenzing_start.sh"
    pdsh -w    ${tenzing_host}   "chmod +x ${tenzing_install_dir}/tenzing_start.sh"

    pdsh -w    ${tenzing_host}   "${tenzing_install_dir}/supervisor_setup.sh \"TenzingService_Supervisor\" ${tenzing_install_dir}/tenzing_start.sh ${tenzing_install_dir}/tenzing_error.log ${tenzing_install_dir}/tenzing_out.log"


else
    pdsh -w ${tenzing_host}   "nohup java -cp  ${tenzing_install_dir}/${tenzing_executable_file} com.sherpa.tenzing.remoting.TenzingService    >> ${tenzing_install_dir}/tenzing_out.log &"
    pdsh -w ${tenzing_host}   "nohup java -cp  ${tenzing_install_dir}/${tenzing_executable_file} com.sherpa.tenzing.remoting.TenzingService Db >> ${tenzing_install_dir}/db.log &"
fi











echo "Tenzing Installed Successfully ..."