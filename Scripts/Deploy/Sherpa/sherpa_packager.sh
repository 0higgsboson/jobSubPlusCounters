#!/bin/bash

PACKAGE_DIR=/opt/sherpa/package


# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`

# load configurations & utils functions
source "${CWD}"/configurations.sh
source "${CWD}"/utils.sh

source /etc/environment


if [[ "$AUTH_TYPE" = "ssh"  ]];
then
    echo "SSH based cloning ..."
    if [[ $HADOOP_VERSION =~ .*2.7.* ]]
    then
        MR_REPO_URL=git@github.com:0higgsboson/hadoop2.7.git
    else
        MR_REPO_URL=git@github.com:0higgsboson/mrClient.git
    fi
    HIVE_REPO_URL=git@github.com:0higgsboson/hiveClientSherpa.git
    JOBSUBPLUS_REPO_URL=git@github.com:0higgsboson/jobSubPlusCounters.git
    TZCTCOMMON_REPO_URL=git@github.com:0higgsboson/TzCtCommon.git
    TENZING_REPO_URL=git@github.com:0higgsboson/Tenzing.git
    CLIENTAGENT_REPO_URL=git@github.com:0higgsboson/ClientAgent.git
else
   echo "User/Password based cloning ..."
   if [[ $HADOOP_VERSION =~ .*2.7.* ]]
    then
        MR_REPO_URL=https://github.com/0higgsboson/hadoop2.7.git
    else
        MR_REPO_URL=https://github.com/0higgsboson/mrClient.git
    fi
    HIVE_REPO_URL=https://github.com/0higgsboson/hiveClientSherpa.git
    JOBSUBPLUS_REPO_URL=https://github.com/0higgsboson/jobSubPlusCounters.git
    TZCTCOMMON_REPO_URL=https://github.com/0higgsboson/TzCtCommon.git
    TENZING_REPO_URL=https://github.com/0higgsboson/Tenzing.git
    CLIENTAGENT_REPO_URL=https://github.com/0higgsboson/ClientAgent.git
fi

if [[ $HADOOP_VERSION =~ .*2.7.* ]]
then
    MR_SRC_DIR=hadoop2.7
    ACTIVE_PROFILE=H2.7.1
else
    MR_SRC_DIR=mrClient
    ACTIVE_PROFILE=H2.6
fi


# Create Directory Structure
print "Creating dir structure ..."
mkdir -p $mr_client_src_dir
mkdir -p $hive_client_src_dir
mkdir -p $hadoop_src_dir
mkdir -p $sherpa_src_dir
mkdir -p $common_src_dir
mkdir -p $tenzing_src_dir
mkdir -p $clientagent_src_dir


function fetchCode(){
    clone_dir=$1
    repo_name=$2
    repo_url=$3

    if [ -d "${clone_dir}/${repo_name}/" ]; then
        echo "Pulling latest code ..."
        cd ${clone_dir}/${repo_name}/
        git pull origin ${BRANCH_NAME}
    else
        echo "Cloning repo ..."
        cd ${clone_dir}
        git clone ${repo_url}
    fi

}


##########################################################   Cloning Repo's    ####################################################################

if [[ "$CLONE_REPOS" = "yes"  ]];
then
    printHeader "Cloning Repo's"

    print "Cloning TzCtCommon Project"
    fetchCode ${common_src_dir} TzCtCommon ${TZCTCOMMON_REPO_URL}

    print "Cloning Custom Hive Project"
    fetchCode ${hive_client_src_dir} hiveClientSherpa ${HIVE_REPO_URL}

    print "Cloning custom MR Project"
    fetchCode ${mr_client_src_dir} ${MR_SRC_DIR} ${MR_REPO_URL}

    print "Cloning Tenzing Project"
    fetchCode ${tenzing_src_dir} Tenzing ${TENZING_REPO_URL}

    print "Cloning Client Agent Project"
    fetchCode ${clientagent_src_dir} ClientAgent ${CLIENTAGENT_REPO_URL}

fi


#
#   Installing TzCtCommon
# ======================================================================================================================================

printHeader "Installing TzCtCommon Project"
cd ${common_src_dir}/TzCtCommon/
mvn clean install -DskipTests  -P${ACTIVE_PROFILE}


#
#   Packaging Tenzing
# ======================================================================================================================================

printHeader "Packaging Tenzing"
cd ${tenzing_src_dir}/Tenzing/
mvn clean package -DskipTests  -P${ACTIVE_PROFILE}



#
#   Packaging Client Agent
# ======================================================================================================================================

printHeader "Packaging Client Agent"
cd ${clientagent_src_dir}/ClientAgent/
mvn clean package -DskipTests  -P${ACTIVE_PROFILE}



#
#   Installing Hive Client
# ======================================================================================================================================

printHeader "Installing Hive Client"
cd $hive_client_src_dir/hiveClientSherpa
mvn clean package -pl ql,cli  -Phadoop-2  -DskipTests

#
#   Installing MR Client
# ======================================================================================================================================

printHeader "Installing MR Client"
cd ${mr_client_src_dir}/${MR_SRC_DIR}
mvn clean package -Pdist -DskipTests


# Creates tmp dir
mkdir -p ${PACKAGE_DIR}
cd ${PACKAGE_DIR}
rm -r sherpa
rm sherpa.tar.gz
mkdir sherpa

print "Copying Jars ..."

if [[ $HADOOP_VERSION =~ .*2.7.* ]]
then
    cp "${mr_client_src_dir}/${MR_SRC_DIR}/target/hadoop-mapreduce-client-core-2.7.1.jar"  ${PACKAGE_DIR}/sherpa/
else
    cp "${mr_client_src_dir}/${MR_SRC_DIR}/target/hadoop-mapreduce-client-core-${HADOOP_VERSION}.jar"  ${PACKAGE_DIR}/sherpa/
fi

cp   "${hive_client_src_dir}/hiveClientSherpa/cli/target/hive-cli-1.2.1.jar"                       ${PACKAGE_DIR}/sherpa/
cp   "${hive_client_src_dir}/hiveClientSherpa/ql/target/hive-exec-1.2.1.jar"                       ${PACKAGE_DIR}/sherpa/

cp  ${clientagent_src_dir}/ClientAgent/target/ClientAgent-1.0-jar-with-dependencies.jar            ${PACKAGE_DIR}/sherpa/

cp  "${common_src_dir}/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar"                 ${PACKAGE_DIR}/sherpa/
cp  "${CWD}/sherpa.properties"                                                                     ${PACKAGE_DIR}/sherpa/
cp  "${CWD}/Customer/ca_kill.sh"                                                                   ${PACKAGE_DIR}/sherpa/
cp  "${CWD}/Customer/client_agent_installer.sh"                                                    ${PACKAGE_DIR}/sherpa/
cp  "${CWD}/Customer/installer.sh"                                                                 ${PACKAGE_DIR}/sherpa/
cp  "${CWD}/supervisor_setup.sh"                                                                   ${PACKAGE_DIR}/sherpa/

tar -czvf sherpa.tar.gz sherpa/
rm -r sherpa

echo "Done packaging sherpa artifacts ..."


