#!/bin/bash

#
# Installs Tomcat web container & monitors its process using Supervisor
#

if [ "$#" -ne 1 ]; then
    echo "Usage: Requires one argument Install_Type "
    echo "Where Install Type is either Tenzing or CA"
    exit
fi


if [[ "$1" != "Tenzing" && "$1" != "CA"  ]]; then
   echo "Error: Install Type should be either Tenzing or CA"
   exit
fi

installType=$1

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`


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
  echo "Error: Please install sherpa configuration file ..."
  exit
fi



if [[ "${installType}" == "Tenzing" ]]; then
    port=${tenzing_port}
    install_dir=${tenzing_basepath}
else
    port=${clientagent_port}
    install_dir=${clientagent_basepath}
fi

echo "${installType}       Port: ${port}        Install Dir: ${install_dir}"




if [ -z ${tomcat_version} ]; then
	echo "Error: Please set tomcat.version configuration in ${file} file"
    exit
else
    echo "Tomcat Version: ${tomcat_version}"
fi


if [ -z ${tomcat_install_dir} ]; then
	echo "Error: Please set tomcat.install.dir configuration in ${file} file"
    exit
else
    echo "Tomcat Path: ${tomcat_install_dir}"
fi


if [ -z ${port} ]; then
	echo "Error: Please set ${installType} port configuration in ${file} file"
    exit
else
    echo "Tomcat Port: ${port}"
fi

if [ -z ${install_dir} ]; then
	echo "Error: Please set ${installType} basepath configuration in ${file} file"
    exit
else
    echo "${installType} Dir: ${install_dir}"
fi



if [ -d "${tomcat_install_dir}/apache-tomcat-${tomcat_version}/" ]; then
    echo "Error: An existing installation of tomcat found, please un-install the existing one before proceeding to install a new one"
    exit
fi


echo "Creating dir structure ..."
mkdir -p  ${install_dir}
mkdir -p ${tomcat_install_dir}
cd ${tomcat_install_dir}


if [  -f  "/etc/redhat-release" ];
then
    sudo yum -y install wget
fi



if [ ! -f  "/etc/redhat-release" ];
then
    apt-get -y install  openjdk-7-jre
    apt-get -y install  openjdk-7-jdk
else
    yum -y install java-1.7.0-openjdk-devel
fi




echo "Downloading Tomcat apache-tomcat-${tomcat_version} ..."
wget http://www-us.apache.org/dist/tomcat/tomcat-8/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz
tar -xzvf apache-tomcat-${tomcat_version}.tar.gz

tomcat_home=${tomcat_install_dir}/apache-tomcat-${tomcat_version}/

echo "Configuring Tomcat Port ..."
textToBeReplaced="<Connector port=\"8080\""
textReplaceWith="<Connector port=\"${port}\""
sed -i "s~${textToBeReplaced}~${textReplaceWith}~" ${tomcat_home}/conf/server.xml






echo "Installing Supervisor ..."
if [ ! -f  "/etc/redhat-release" ];
then
    apt-get install -y supervisor
else
    #yum install -y supervisor
    yum install python-setuptools
    easy_install supervisor
    echo_supervisord_conf > /etc/supervisord.conf
    mkdir /etc/supervisord.d/
    echo "[include]
files = /etc/supervisord.d/*.ini"  >> /etc/supervisord.conf
    supervisord

    cp supervisor_init.sh  /etc/rc.d/init.d/supervisord

fi
echo "Done Installing Supervisor ..."


echo "Adding Tomcat to Supervisor ..."
cd ${CWD}
./supervisor_setup.sh "Tomcat" "${tomcat_home}/bin/catalina.sh run"   ${install_dir}/tomcat_error.log    ${install_dir}/tomcat_out.log

