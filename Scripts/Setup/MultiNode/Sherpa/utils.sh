#!/bin/bash

# Printing Functions
function print(){
  printf "\n"
  echo "$1"
  echo "================================"
}

function printHeader(){
  printf "\n\n"
  echo "**************************************** $1 ***********************************************"
}


function setupMasterNode() {
  # takes hosts file as input and defines master node
  # $1 is hosts file

  # Sets first host as master node
     # converts relative path to absolute path
  hosts_file=`readlink -f $1`
     # reads in input file into an array
  readarray hosts < $hosts_file
     # trims trailing spaces and newline at the end of string
  master=`echo ${hosts[0]} | xargs`

}


function installPdsh(){
  # takes hosts file and master node as input
  # $1 is hosts file
  # $2 is master node

  hosts_list=$1
  master_node=$2

  # Setting up pdsh utility
  print "Setting up PDSH command on all hosts"
  sudo apt-get -y install pdsh
  export PDSH_RCMD_TYPE=ssh

  # installs on all nodes excluding master
  pdsh -w ^${hosts_list} -x ${master_node}  "apt-get -y install pdsh"
  pdsh -w ^${hosts_list} -x ${master_node}  "export PDSH_RCMD_TYPE=ssh"

}

function installPdshSingleNode(){
  # takes host as input
  # $1 is host name

  host=$1

  # Setting up pdsh utility
  print "Setting up PDSH command on: ${host}"
  sudo apt-get -y install pdsh
  export PDSH_RCMD_TYPE=ssh

  pdsh -w ${host}   "apt-get -y install pdsh"
  pdsh -w ${host}   "export PDSH_RCMD_TYPE=ssh"

}


function installPreReqs(){
  # takes hosts file as input
  # $1 is hosts file

  hosts_list=$1

  print "Updating ..."
  pdsh -w ^${hosts_list}  "sudo apt-get update"


  # Install Java
  print "Installing Java ..."
  pdsh -w ^${hosts_list} "sudo apt-get -y install openjdk-7-jre"
  pdsh -w ^${hosts_list} "sudo apt-get -y install openjdk-7-jdk"


  # Its a fix to use java version 7 on GCloud machines, comment that out if you are already using java 7
  print "Updating java alternatives"
  pdsh -w ^${hosts_list} 'update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/java-7-openjdk-amd64/bin/java" 5000'
  pdsh -w ^${hosts_list} 'update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/java-7-openjdk-amd64/bin/javac" 5000'


  # Installs Git if not installed already
  print "Checking git install..."
  git >> /dev/null
  if [ "$?" -ne 0 ]; then
      apt-get -y install git
  fi

# Installs Maven if not installed already
  print "Checking Maven install..."
  mvn >> /dev/null
  if [ "$?" -ne 0 ]; then
      apt-get -y install maven
  fi



  # Define Java Home
  print "Defining Java Home ..."

  JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
  pdsh -w ^${hosts_list} "grep -q -F \"export JAVA_HOME=$JAVA_HOME\" /etc/environment || echo \"export JAVA_HOME=$JAVA_HOME\" >> /etc/environment"

}



function installJava(){
  # takes hosts name as input
  # $1 is host name

  host=$1

  print "Updating ..."
  pdsh -w ${host}  "sudo apt-get update"


  # Install Java
  print "Installing Java ..."
  pdsh -w ${host} "sudo apt-get -y install openjdk-7-jre"
  pdsh -w ${host} "sudo apt-get -y install openjdk-7-jdk"


  # Its a fix to use java version 7 on GCloud machines, comment that out if you are already using java 7
  print "Updating java alternatives"
  pdsh -w ${host} 'update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/java-7-openjdk-amd64/bin/java" 5000'
  pdsh -w ${host} 'update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/java-7-openjdk-amd64/bin/javac" 5000'


  # Define Java Home
  print "Defining Java Home ..."

  JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
  pdsh -w ${host} "grep -q -F \"export JAVA_HOME=$JAVA_HOME\" /etc/environment || echo \"export JAVA_HOME=$JAVA_HOME\" >> /etc/environment"

}




function defineEnvironmentVar(){
  # takes two inputs
  # first input is variable name
  # second input is variable value

  name=$1
  value=$2

  # check if variable is already defined, add only if variable not defined
  grep -q -F "export $name=$value" /etc/environment || echo "export $name=$value" >> /etc/environment

  # add environment file in user's bashrc and profile files
  grep -q -F "source /etc/environment" /root/.bashrc || echo "source /etc/environment" >> /root/.bashrc
  grep -q -F "source /etc/environment" /root/.profile || echo "source /etc/environment" >> /root/.profile
  source /etc/environment

  # For worker nodes
  pdsh -w ^${hosts_list} -x ${master_node}  "echo \"export $name=$value\" >> /etc/environment"
  pdsh -w ^${hosts_list} -x ${master_node}  "grep -q -F \"source /etc/environment\" /root/.bashrc || echo \"source /etc/environment\" >> /root/.bashrc"
  pdsh -w ^${hosts_list} -x ${master_node}  "grep -q -F \"source /etc/environment\" /root/.profile || echo \"source /etc/environment\" >> /root/.profile"


}


function addToPath(){
  # takes one input of path

  customPath=$1
  File=/etc/environment
  if grep -q "$customPath" "$File"; then
      echo "Path is already defined ..."
  else
    echo "export PATH=$PATH:$customPath"   >> /etc/environment

    # add environment file in user's bashrc and profile files
    grep -q -F "source /etc/environment" /root/.bashrc || echo "source /etc/environment" >> /root/.bashrc
    grep -q -F "source /etc/environment" /root/.profile || echo "source /etc/environment" >> /root/.profile

  fi
  source /etc/environment


  # For worker nodes
  pdsh -w ^${hosts_list} -x ${master_node}  "echo \"export PATH=$PATH:$customPath\"   >> /etc/environment"
  pdsh -w ^${hosts_list} -x ${master_node}  "grep -q -F \"source /etc/environment\" /root/.bashrc || echo \"source /etc/environment\" >> /root/.bashrc"
  pdsh -w ^${hosts_list} -x ${master_node}  "grep -q -F \"source /etc/environment\" /root/.profile || echo \"source /etc/environment\" >> /root/.profile"

}

