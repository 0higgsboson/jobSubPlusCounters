#!/bin/bash

source configurations.sh

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
  echo "sed -i \"s~$1~$2~\" $3"
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



function getLearningWeights(){
  # Arg#1  number of solution candidates
  # Arg#2  learning weight

  #echo "( Learning Weight=$2, Solution Candidates=$1 )"
  learingWeightsStr="["
  COUNTER=0
  while [ ${COUNTER} -lt  $1 ]
  do
     if [ "${learingWeightsStr}" = "[" ]
     then
          learingWeightsStr="${learingWeightsStr}\"$2\""
     else
          learingWeightsStr="${learingWeightsStr},\"$2\""
     fi
     COUNTER=$[$COUNTER +1]
  done

  learingWeightsStr="${learingWeightsStr}]"
  #echo "Learning Weights String: ${learingWeightsStr}"
}



function initConfigurations(){
  # takes cost objective as input
  # takes solution candidates as input
  # takes learning weights string as input
  # takes tag as input

  source configurations.sh
  echo "Creating empty configuration files ..."
  costObjectiveArg=$1
  solutionCandiateArg=$2
  relativeWeightsStrArg=$3
  tagArg=$4

  NOW=$(date +"%Y-%m-%d-%H-%M")
  tempDir="${tagArg}-${NOW}"
  workloadMetaDir="${backup_base_dir}/${tempDir}"

  mkdir -p "${workloadMetaDir}"
  rm -f /opt/sherpa/configs.json /opt/sherpa/clientDB.txt /opt/sherpa/SherpaSequenceNos.txt /opt/sherpa/TenzingDB.txt /opt/sherpa/TenzingMetadata.txt

  mkdir -p /opt/sherpa/
  touch /opt/sherpa/clientDB.txt
  touch /opt/sherpa/SherpaSequenceNos.txt
  touch /opt/sherpa/TenzingDB.txt
  touch /opt/sherpa/configs.json
  cp tunedparams.json /opt/sherpa/tunedparams.json
  echo '{
            "costObjective":'"\"${costObjectiveArg}\""',
            "numCandidateSolutions":"'"${solutionCandiateArg}"'",
            "relativeLearningWeights":'"${relativeWeightsStrArg}"',
            "coolOffFactor":1.0,
            "useBestWhenConverged":false,
            "gradientMultiplier":"0.0"
          }' >> /opt/sherpa/TenzingMetadata.txt

# Restart Tenzing and Client Agent
  kill `jps | grep TzCtCommon | awk '{print $1}'`
#  java -jar $HADOOP_HOME/share/hadoop/mapreduce/lib/TzCtCommon-1.0-jar-with-dependencies.jar &
  java -jar $HADOOP_HOME/share/hadoop/mapreduce/lib/TzCtCommon-1.0-jar-with-dependencies.jar > ~/sherpa/tzctcommonlog-${tagArg}.txt 2>&1 &
  jps | grep TzCtCommon
 }




function createLearningConfigurations2(){
  # takes cost objective as input
  # takes solution candidates as input
  # takes learning weights string as input
  # takes tag as input

  costObjectiveArg=$1
  solutionCandiateArg=$2
  relativeWeightsStrArg=$3
  tagArg=$4

    pathPrefix=/root/HiBenchBackup
    NOW=$(date +"%Y-%m-%d-%H-%M")
    tempDir="${tagArg}-${NOW}"
    path="${pathPrefix}/${tempDir}"
    mkdir -p ${path}
    cp -r /opt/sherpa/* "${path}"/
    rm -r /opt/sherpa/*

    mkdir -p /opt/sherpa/
    touch /opt/sherpa/clientDB.txt
    touch /opt/sherpa/SherpaSequenceNos.txt
    touch /opt/sherpa/TenzingDB.txt

  echo '{
            "numDimensions":"6",
            "costObjective":'"\"${costObjectiveArg}\""',
            "numCandidateSolutions":"'"${solutionCandiateArg}"'",
            "relativeLearningWeights":'"${relativeWeightsStrArg}"',
            "coolOffFactor":1.0,
            "useBestWhenConverged":false,
            "gradientMultiplier":"0.0"
          }' >> /opt/sherpa/TenzingMetadata.txt
 }






function createLearningConfigurations(){
  # takes cost objective as input
  costObjective=$1

  pathPrefix=/root/HiBenchBackup
  NOW=$(date +"%Y-%m-%d-%H-%M")
  tempDir="${costObjective}_DBs_Backup-${NOW}"
  path="${pathPrefix}/${tempDir}"
  mkdir -p ${path}
  cp -r /opt/sherpa/* "${path}"/
  rm -r /opt/sherpa/*

  mkdir -p /opt/sherpa/
  touch /opt/sherpa/clientDB.txt
  touch /opt/sherpa/SherpaSequenceNos.txt
  touch /opt/sherpa/TenzingDB.txt


  echo '{
            "numDimensions":"6",
            "costObjective":'"\"${costObjective}\""',
            "numCandidateSolutions":"4",
            "relativeLearningWeights":[".2",".2",".2",".4"],
            "coolOffFactor”:1.0,
            "useBestWhenConverged":false,
            "gradientMultiplier":"0.0"
          }' >> /opt/sherpa/TenzingMetadata.txt

 }




function createLearningConfgis(){
  # takes a parameter for number of solution candidates
  numSolutions=$1
  rm /opt/sherpa/TenzingMetadata.txt

  if [ ${numSolutions} -eq 4 ]
  then
    echo '{
            "numDimensions":"6",
            "costObjective":"Latency",
            "numCandidateSolutions":"4",
            "relativeLearningWeights":[".2",".2",".2",".4"],
            "coolOffFactor”:1.0,
            "useBestWhenConverged":false,
            "gradientMultiplier":"0.0"
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
