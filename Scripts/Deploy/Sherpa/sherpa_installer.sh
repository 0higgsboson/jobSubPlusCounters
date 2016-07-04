#!/bin/bash
#set -e

if [ "$#" -lt 2 ]; then
    echo "Usage: command [arguments]"
    echo "./sherpa_installer package hadoop_version [build_code]        Packages CA & Client installers for customers "
    echo "./sherpa_installer install hadoop_version [build_code]        Install MR & Hive Clients "
    echo "./sherpa_installer tenzing hadoop_version [build_code]      Packages Tenzing "
    echo "./sherpa_installer deploy   hadoop_version deployment_path"

    echo "Supported hadoop versions : 2.7.* | 2.6.* "
    echo "Setting build code to yes will build the jars, set it to no when code already built and jars/wars files are present, defaults to yes"
    exit
fi


command=$1
HADOOP_VERSION=$2
if [ "$#" -ge 3 ]; then
    if [[ "$command" = "deploy"  ]];
    then
        build_code=yes
        CLONE_REPOS=yes
        deployment_path=$3
    else
        build_code=$3
    fi
else
    build_code=yes
fi



if [[ "${command}" != "package" && "${command}" != "install" && "${command}" != "tenzing"  && "${command}" != "deploy" ]]; then
    echo "Error: Supported commands are [package | install | tenzing | deploy ]  ..."
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


#print "Updating ..."
#runCommand "update"

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




if [[ "${build_code}" = "yes"  ]]; then
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
    cd ${tenzing_src_dir}/Tenzing/tenzing-core/
    mvn clean package -DskipTests  -P${ACTIVE_PROFILE}

    cd ${tenzing_src_dir}/Tenzing/RestServices/
    mvn clean package -DskipTests  -P${ACTIVE_PROFILE}

    #
    #   Packaging Client Agent
    # ======================================================================================================================================

    printHeader "Packaging Client Agent"
    cd ${clientagent_src_dir}/ClientAgent/ca-core/
    mvn clean package -DskipTests  -P${ACTIVE_PROFILE}

    cd ${clientagent_src_dir}/ClientAgent/ca-services/
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
else
    echo "Skipping code compilation ..."
fi




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
    echo "Packaging Sherpa CA & Client Artifacts ..."

    mkdir -p ${PACKAGE_DIR}
    cd ${PACKAGE_DIR}
    rm -r sherpa
    rm sherpa.tar.gz
    mkdir -p sherpa


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
    cp  "${CWD}/supervisor_init.sh"                                                                   ${PACKAGE_DIR}/sherpa/
    cp  "${CWD}/tomcat_setup.sh"                                                                       ${PACKAGE_DIR}/sherpa/


#    mkdir -p sherpa/MR
#    mkdir -p sherpa/Hive/Cli
#    mkdir -p sherpa/Hive/Ql
#
#    cp "${mr_client_src_dir}/${MR_SRC_DIR}/pom.xml"                                                    ${PACKAGE_DIR}/sherpa/MR/
#    cp "${mr_client_src_dir}/${MR_SRC_DIR}/src/main/java/org/apache/hadoop/mapreduce/Job.java"         ${PACKAGE_DIR}/sherpa/MR/
#    cp "${mr_client_src_dir}/${MR_SRC_DIR}/src/main/java/org/apache/hadoop/mapreduce/SherpaJob.java"   ${PACKAGE_DIR}/sherpa/MR/
#
#
#    cp "${hive_client_src_dir}/hiveClientSherpa/cli/pom.xml"                                             ${PACKAGE_DIR}/sherpa/Hive/Cli/
#    cp "${hive_client_src_dir}/hiveClientSherpa/cli/src/java/org/apache/hadoop/hive/cli/CliDriver.java"  ${PACKAGE_DIR}/sherpa/Hive/Cli/
#
#
#    cp "${hive_client_src_dir}/hiveClientSherpa/ql/pom.xml"                                                       ${PACKAGE_DIR}/sherpa/Hive/Ql/
#    cp "${hive_client_src_dir}/hiveClientSherpa/ql/src/java/org/apache/hadoop/hive/ql/session/SessionState.java"  ${PACKAGE_DIR}/sherpa/Hive/Ql/


    tar -czvf sherpa.tar.gz sherpa/
    rm -r sherpa

    echo "Done packaging sherpa artifacts ..."





elif [ "${command}" == "tenzing" ]; then
    echo "Packaging Tenzing Artifacts ..."

    mkdir -p ${PACKAGE_DIR}
    cd ${PACKAGE_DIR}
    rm -r tenzing
    rm tenzing.tar.gz
    mkdir tenzing

    print "Copying Tenzing Files ..."

    cp  ${tenzing_src_dir}/Tenzing/RestServices/target/tenzing-services.war                            ${PACKAGE_DIR}/tenzing/
    cp  "${CWD}/tenzing_installer.sh"                                                                  ${PACKAGE_DIR}/tenzing/
    cp  "${CWD}/sherpa.properties"                                                                     ${PACKAGE_DIR}/tenzing/
    cp  "${CWD}/tunedparams.json"                                                                      ${PACKAGE_DIR}/tenzing/
    cp  "${CWD}/Mongo/db_installer.sh"                                                                 ${PACKAGE_DIR}/tenzing/
    cp  "${CWD}/supervisor_setup.sh"                                                                   ${PACKAGE_DIR}/tenzing/
    cp  "${CWD}/supervisor_init.sh"                                                                    ${PACKAGE_DIR}/tenzing/
    cp  "${CWD}/tomcat_setup.sh"                                                                       ${PACKAGE_DIR}/tenzing/


    tar -czvf tenzing.tar.gz tenzing/
    rm -r tenzing

    echo "Done packaging tenzing artifacts ..."




fi
