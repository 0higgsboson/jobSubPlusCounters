#!/bin/bash

function runCommand(){
    # takes command as input
    if [ ! -f  "/etc/redhat-release" ];
    then
        apt-get $1
    else
        yum  $1
    fi
}

function runJavaInstallCommand(){
    # takes command as input
    if [ ! -f  "/etc/redhat-release" ];
    then
        if [[ "$JAVA_VERSION" -eq 8  ]]; then
           sudo add-apt-repository ppa:openjdk-r/ppa
           sudo apt-get update
           sudo apt-get -y install openjdk-8-jre
           sudo apt-get -y install openjdk-8-jdk

           sudo update-java-alternatives -s java-1.8.0-openjdk-amd64
 
           JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

        elif [[ "$JAVA_VERSION" -eq 7  ]]; then
           sudo apt-get update
           sudo apt-get -y install openjdk-7-jre
           sudo apt-get -y install openjdk-7-jdk

           sudo update-java-alternatives -s java-1.7.0-openjdk-amd64

           JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
        fi

        grep -q -F "export JAVA_HOME=" /etc/environment || echo "export JAVA_HOME=$JAVA_HOME" >> /etc/environment
        sed -i 's;export JAVA_HOME=.*$;export JAVA_HOME='$JAVA_HOME';' /etc/environment

    else
        yum -y install java-1.7.0-openjdk-devel
    fi
}





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

  if [[ "$JAVA_VERSION" -eq 8  ]]; then
     #print "Removing jdk-7 ..."
     #pdsh -w ^${hosts_list} "sudo apt-get -y remove openjdk-7*"

     print "Adding repository"
     pdsh -w ^${hosts_list} "sudo add-apt-repository ppa:openjdk-r/ppa"

     print "Updating ..."
     pdsh -w ^${hosts_list}  "sudo apt-get update"

     # Install Java
     print "Installing Java ..."
     pdsh -w ^${hosts_list} "sudo apt-get -y install openjdk-8-jre"
     pdsh -w ^${hosts_list} "sudo apt-get -y install openjdk-8-jdk"

     # Set the default if you have more than one java versions
     print "Set the default java version is jdk-8 ..."
     pdsh -R ssh -w ^${hosts_list} "sudo update-java-alternatives -s java-1.8.0-openjdk-amd64"

     JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
    
  elif [[ "$JAVA_VERSION" -eq 7  ]]; then
     #print "Removing jdk-7 ..."
     #pdsh -w ^${hosts_list} "sudo apt-get purge openjdk-8*"

     print "Updating ..."
     pdsh -w ^${hosts_list}  "sudo apt-get update"

     # Install Java
     print "Installing Java ..."
     pdsh -w ^${hosts_list} "sudo apt-get -y install openjdk-7-jre"
     pdsh -w ^${hosts_list} "sudo apt-get -y install openjdk-7-jdk"
  
     # Set the default if you have more than one java versions
     print "Set the default java version is jdk-7..."
     pdsh -R ssh -w ^${hosts_list} "sudo update-java-alternatives -s java-1.7.0-openjdk-amd64"

     JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
  fi

  # Define Java Home
  print "Defining Java Home ..."

  pdsh -w ^${hosts_list} "grep -q -F \"export JAVA_HOME=\" /etc/environment || echo \"export JAVA_HOME=$JAVA_HOME\" >> /etc/environment"
  pdsh -R ssh -w ^${hosts_list} "sed -i 's;export JAVA_HOME=.*$;export JAVA_HOME='$JAVA_HOME';' /etc/environment" 

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



}



function installJava(){
  # takes hosts name as input
  # $1 is host name

  host=$1

  if [[ "$JAVA_VERSION" -eq 8  ]]; then
     #print "Removing jdk-7 ..."
     #pdsh -w ^${host} "sudo apt-get -y remove openjdk-7*"

     print "Adding repository"
     pdsh -w ^${host} "sudo add-apt-repository ppa:openjdk-r/ppa"

     print "Updating ..."
     pdsh -w ^${host}  "sudo apt-get update"

     # Install Java
     print "Installing Java ..."
     pdsh -w ^${host} "sudo apt-get -y install openjdk-8-jre"
     pdsh -w ^${host} "sudo apt-get -y install openjdk-8-jdk"

     # Set the default if you have more than one java versions
     print "Set the default java version is jdk-8 ..."
     pdsh -R ssh -w ^${host} "sudo update-java-alternatives -s java-1.8.0-openjdk-amd64"

     JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
    
  elif [[ "$JAVA_VERSION" -eq 7  ]]; then
     #print "Removing jdk-7 ..."
     #pdsh -w ^${host} "sudo apt-get purge openjdk-8*"

     print "Updating ..."
     pdsh -w ^${host}  "sudo apt-get update"

     # Install Java
     print "Installing Java ..."
     pdsh -w ^${host} "sudo apt-get -y install openjdk-7-jre"
     pdsh -w ^${host} "sudo apt-get -y install openjdk-7-jdk"
  
     # Set the default if you have more than one java versions
     print "Set the default java version is jdk-7..."
     pdsh -R ssh -w ^${host} "sudo update-java-alternatives -s java-1.7.0-openjdk-amd64"

     JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
  fi

  # Define Java Home
  print "Defining Java Home ..."

  pdsh -w ^${host} "grep -q -F \"export JAVA_HOME=\" /etc/environment || echo \"export JAVA_HOME=$JAVA_HOME\" >> /etc/environment"
  pdsh -R ssh -w ^${host} "sed -i 's;export JAVA_HOME=.*$;export JAVA_HOME='$JAVA_HOME';' /etc/environment"

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

