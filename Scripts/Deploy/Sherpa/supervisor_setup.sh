#!/bin/bash

if [ $# -eq 4 ]
  then
    program_name=$1
    program_path=$2
    std_err_file=$3
    std_out_file=$4
  else
    echo "Usage: program_name program_path stderr_file stdout_file"
    exit
fi

SUPERVISOR_CONF_DIR=/etc/supervisor/conf.d/
conf_file="${SUPERVISOR_CONF_DIR}/${program_name}.conf"

echo "Installing Supervisor ..."
apt-get install -y supervisor

echo "Removing existing conf file if any ..."
rm ${conf_file}

supervisorctl stop   ${program_name}
supervisorctl remove ${program_name}



echo "Creating supervisor conf file: ${conf_file} ..."

echo "[program:${program_name}]" >> ${conf_file}
echo "command=${program_path}"  >> ${conf_file}
echo "autostart=true"  >> ${conf_file}
echo "autorestart=true"  >> ${conf_file}
echo "stderr_logfile=${std_err_file}"  >> ${conf_file}
echo "stdout_logfile=${std_out_file}"  >> ${conf_file}

echo "Updating Supervisor ..."
supervisorctl reread
supervisorctl update

