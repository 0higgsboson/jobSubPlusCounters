#!/bin/bash
#set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: command [arguments]"
    echo "./sherpa_installer package hadoop_version"
    echo "./sherpa_installer install hadoop_version"
    echo "Supported hadoop versions : 2.7.* | 2.6.* "
    exit
fi

command=$1
HADOOP_VERSION=$2

if [[ "${command}" != "package" && "${command}" != "install" ]]; then
    echo "Error: Command not supported ..."
    exit
fi


# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`


# load configurations & utils functions
source "${CWD}"/configurations.sh
source "${CWD}"/utils.sh


mr_client_src_dir="${CHECK_IN_BASE_DIR}/mr_client_src/"
hive_client_src_dir="${CHECK_IN_BASE_DIR}/hive_client_src"
jobSubPlus_src_dir="${CHECK_IN_BASE_DIR}/jobSubPub_src"
common_src_dir="${CHECK_IN_BASE_DIR}/tzCtCommon"
tenzing_src_dir="${CHECK_IN_BASE_DIR}/tenzing_src"
clientagent_src_dir="${CHECK_IN_BASE_DIR}/clientagent_src"


git_protocol=https://github.com/
if [[ "$AUTH_TYPE" = "ssh"  ]];
then
    git_protocol=git@github.com:
fi

if [[ ${HADOOP_VERSION} == *"2.7"* ]]; then
    MR_REPO_URL=${git_protocol}0higgsboson/hadoop2.7.git
    MR_SRC_DIR=hadoop2.7
    ACTIVE_PROFILE=H2.7.1
else
    MR_REPO_URL=${git_protocol}0higgsboson/mrClient.git
    MR_SRC_DIR=mrClient
    ACTIVE_PROFILE=H2.6
fi
HIVE_REPO_URL=${git_protocol}0higgsboson/hiveClientSherpa.git
JOBSUBPLUS_REPO_URL=${git_protocol}0higgsboson/jobSubPlusCounters.git
TZCTCOMMON_REPO_URL=${git_protocol}0higgsboson/TzCtCommon.git
TENZING_REPO_URL=${git_protocol}0higgsboson/Tenzing.git
CLIENTAGENT_REPO_URL=${git_protocol}0higgsboson/ClientAgent.git



# Create Directory Structure
print "Creating dir structure ..."
mkdir -p $mr_client_src_dir
mkdir -p $hive_client_src_dir
mkdir -p $common_src_dir
mkdir -p $tenzing_src_dir
mkdir -p $clientagent_src_dir


print "Updating ..."
runCommand "update"

print "Installing Java ..."
runJavaInstallCommand
#export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/

print "Checking git install..."
runCommand "-y install git"

print "Checking maven install.."
runCommand "-y install maven"

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
        git checkout ${BRANCH_NAME}
    fi

}

##########################################################   Cloning Repo's    ####################################################################

if [[ "$CLONE_REPOS" = "yes"  ]];
then
    printHeader "Cloning Repo's"

    print "Cloning JobSubPlus Project"
    fetchCode ${jobSubPlus_src_dir} jobSubPlusCounters ${JOBSUBPLUS_REPO_URL}

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

printHeader "Packaging Hive Client"
cd $hive_client_src_dir/hiveClientSherpa
mvn clean package -pl ql,cli  -Phadoop-2  -DskipTests



#
#   Installing MR Client
# ======================================================================================================================================

printHeader "Packaging MR Client"
cd ${mr_client_src_dir}/${MR_SRC_DIR}
mvn clean package -Pdist -DskipTests



if [ "${command}" == "install" ]; then

    print "Installing Hive Client..."
    mkdir -p ${INSTALL_DIR}

    cp  ${hive_client_src_dir}/hiveClientSherpa/cli/target/hive-cli-${HIVE_VERSION}.jar                               ${INSTALL_DIR}/
    cp  ${hive_client_src_dir}/hiveClientSherpa/ql/target/hive-exec-${HIVE_VERSION}.jar                               ${INSTALL_DIR}/
    cp  ${common_src_dir}/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar                                  ${INSTALL_DIR}/
    cp   ${CWD}/sherpa.properties    /opt/sherpa.properties
    echo "Hive Client Installed ..."

    print "Installing MR Client..."
    if [[ ${HADOOP_VERSION} == *"2.7"* ]]
    then
       cp   ${mr_client_src_dir}/${MR_SRC_DIR}/target/hadoop-mapreduce-client-core-2.7.1.jar                         ${INSTALL_DIR}/
    else
       cp   ${mr_client_src_dir}/${MR_SRC_DIR}/target/hadoop-mapreduce-client-core-2.6.0.jar                         ${INSTALL_DIR}/
    fi
    echo "MR Client Installed ..."




elif [ "${command}" == "package" ]; then
    echo "Packaging Sherpa Artifacts ..."

    mkdir -p ${PACKAGE_DIR}
    cd ${PACKAGE_DIR}
    rm -r sherpa
    rm sherpa.tar.gz
    mkdir sherpa

    print "Copying Files ..."

    if [[ ${HADOOP_VERSION} == *"2.7"* ]]
    then
        cp "${mr_client_src_dir}/${MR_SRC_DIR}/target/hadoop-mapreduce-client-core-2.7.1.jar"          ${PACKAGE_DIR}/sherpa/
    else
        cp "${mr_client_src_dir}/${MR_SRC_DIR}/target/hadoop-mapreduce-client-core-2.6.0.jar"          ${PACKAGE_DIR}/sherpa/
    fi

    cp   "${hive_client_src_dir}/hiveClientSherpa/cli/target/hive-cli-1.2.1.jar"                       ${PACKAGE_DIR}/sherpa/
    cp   "${hive_client_src_dir}/hiveClientSherpa/ql/target/hive-exec-1.2.1.jar"                       ${PACKAGE_DIR}/sherpa/

    cp  ${clientagent_src_dir}/ClientAgent/ca-core/target/ca-core-1.0-jar-with-dependencies.jar        ${PACKAGE_DIR}/sherpa/
    cp  ${clientagent_src_dir}/ClientAgent/ca-services/target/ca-services.war                          ${PACKAGE_DIR}/sherpa/


    cp  "${common_src_dir}/TzCtCommon/target/TzCtCommon-1.0-jar-with-dependencies.jar"                 ${PACKAGE_DIR}/sherpa/
    cp  "${CWD}/sherpa.properties"                                                                     ${PACKAGE_DIR}/sherpa/
    cp  "${CWD}/Customer/client_agent_installer.sh"                                                    ${PACKAGE_DIR}/sherpa/
    cp  "${CWD}/Customer/installer.sh"                                                                 ${PACKAGE_DIR}/sherpa/
    cp  "${CWD}/supervisor_setup.sh"                                                                   ${PACKAGE_DIR}/sherpa/
    cp  "${CWD}/tomcat_setup.sh"                                                            ${PACKAGE_DIR}/sherpa/


    tar -czvf sherpa.tar.gz sherpa/
    rm -r sherpa

    echo "Done packaging sherpa artifacts ..."

fi