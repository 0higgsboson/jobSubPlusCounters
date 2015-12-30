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


# For Reference
# https://www.digitalocean.com/community/tutorials/the-basics-of-using-the-sed-stream-editor-to-manipulate-text-in-linux
# https://www.digitalocean.com/community/tutorials/using-grep-regular-expressions-to-search-for-text-patterns-in-linux

function setConfiguration(){
  # takes configuration name, value and file as input
  # Updates the configuration value
  # $1 is configuration name
  # $2 is configuration value
  # $3 is configuration file

  echo "Setting up ( $1 = $2 ) in $3 ..."

  # Variables are expanded first by shell, sed is executed next
  # Using ~ as a separator not / because config value itself contains slashes /
  sed -i "s~^$1.*.$~$1      $2~" $3

  # Example
  # sed 's/^hibench.hadoop.home.*.$/hibench.hadoop.home    ${HADOOP_HOME}/' 99-user_defined_properties.conf

}



function replaceText(){
  # takes configuration name, value and file as input
  # Updates the configuration value
  # $1 is configuration name
  # $2 is configuration value
  # $3 is configuration file
  echo "Setting up ( $1 = $2 ) in $3 ..."
  sed -i "s~$1~$2~" $3
}



function printStats(){
  # Takes workload name as input
  # $1 is workload name

  workloadName=$1
  print "Input Data Size :"
  name="$(tr '[:lower:]' '[:upper:]' <<< ${workloadName:0:1})${workloadName:1}"
  hdfs dfs -du -h ${hdfs_master}/HiBench/${name}/Input/

}


function installThrift(){
  sudo apt-get install libboost-dev libboost-test-dev libboost-program-options-dev libevent-dev automake libtool flex bison pkg-config g++ libssl-dev
  wget http://www.us.apache.org/dist/thrift/0.9.3/thrift-0.9.3.tar.gz
  tar -xvzf thrift-0.9.3.tar.gz
  cd thrift-0.9.3
  ./configure
  make
  sudo make install
  thrift -version
}


function createLearningConfgis(){
  # takes a parameter for number of solution candidates
  numSolutions=$1
  rm /opt/sherpa/TenzingMetadata.txt

  if [ ${numSolutions} -eq 4 ]
  then
    echo '{
        "numDimensions":"6",
        "numCandidateSolutions":"4",
        "relativeLearningWeights":[".2",".2",".2",".4"]
        }' >> /opt/sherpa/TenzingMetadata.txt

  elif [ ${numSolutions} -eq 6 ]
  then
    echo '{
      "numDimensions":"6",
      "numCandidateSolutions":"6",
      "relativeLearningWeights":[".2",".2",".2",".2",".2",".4"]
      }' >>   /opt/sherpa/TenzingMetadata.txt

  elif [ ${numSolutions} -eq 8 ]
  then
    echo '{
        "numDimensions":"6",
        "numCandidateSolutions":"8",
        "relativeLearningWeights":[".2",".2",".2",".2",".2",".2",".4",".4"]
        }' >> /opt/sherpa/TenzingMetadata.txt
  fi
 }
