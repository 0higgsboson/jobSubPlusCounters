#!/bin/bash
#set -e

# Save Script Working Dir
CWD=`dirname "$0"`
CWD=`cd "$CWD"; pwd`


# load configurations & utils functions
source "${CWD}"/configurations.sh
source "${CWD}"/utils.sh

function printUsage(){
    echo "Usage: scriptname hadoop_version [build_code]"
    echo "./tenzing_build.sh hadoop_version [yes] "

    echo "Supported hadoop versions : 2.7.* | 2.6.* | hdp 2.3.6 | hdp 2.4.2"
    echo "Setting build code to yes will build the jars, set it to no when code already built and jars/wars files are present, defaults to yes"
    exit
}


if [ "$#" -lt 1 ]; then
   printUsage
fi

git_protocol=https://github.com/
if [[ "$AUTH_TYPE" = "ssh"  ]];
then
    git_protocol=git@github.com:
fi

HADOOP_VERSION=$1
    
ACTIVE_PROFILE=H${HADOOP_VERSION}

if [ "$#" -eq 2 ]; then
     build_code=$2
else
     build_code=yes
fi

tenzing_src_dir="${CHECK_IN_BASE_DIR}/tenzing_src"

TENZING_REPO_URL=${git_protocol}0higgsboson/Tenzing.git

# Create Directory Structure
print "Creating dir structure ..."

mkdir -p $tenzing_src_dir

print "Installing Java ..."
runJavaInstallCommand
#export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/

print "Checking git install..."
runCommand "-y install git"

print "Checking maven install.."
runCommand "-y install maven"

# Installing proto buff 2.5
print "Installing Protobuf ..."
protoc_installed=`protoc --version 2> /dev/null | awk '{print $2}'`
if [ -z "$protoc_installed" -o "$protoc_installed" != "2.5.0" ]; then
    sudo apt-get install build-essential
    wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz
#    wget http://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz
    tar xzvf protobuf-2.5.0.tar.gz
    cd  protobuf-2.5.0
    ./configure
    make
    make check
    sudo make install
    sudo ldconfig
    protoc --version
    cd ..
else
    echo "Protobuf $protoc_installed already installed"
fi

function fetchCode(){
    clone_dir=$1
    repo_name=$2
    repo_url=$3

    echo "Repo: ${repo_url}"
    if [ -d "${clone_dir}/${repo_name}/" ]; then
        echo "Pulling latest code ..."
        cd ${clone_dir}/${repo_name}/
        git pull origin ${BRANCH_NAME}
    else
        echo "Cloning repo ..."
        cd ${clone_dir}
        git clone ${repo_url} --branch ${BRANCH_NAME}
    fi

}

function addBuildNumberToFile(){
    #takes base dir and file as arguement
    base_dir=$1
    file=$2
    echo "Adding Build Numbers To File: $file"
    file_name=$(basename "$file")
    file_extension="${file_name##*.}"
    file_name_without_extension="${file_name%.*}"
    mv ${file}  ${base_dir}/${file_name_without_extension}_Build_${build_number}.${file_extension}
}


function addBuildNumber(){
   #takes base dir as arguement
   base_dir=$1

   build_number=$(shuf -i 1-10000 -n 1)

   for file in "${base_dir}"/*.jar
   do
        addBuildNumberToFile  ${base_dir}/  $file
   done


   for file in "${base_dir}"/*.war
   do
        addBuildNumberToFile  ${base_dir}/  $file
   done

}

##########################################################   Cloning Repo's    ####################################################################

if [[ "$CLONE_REPOS" = "yes"  ]];
then
    printHeader "Cloning Repo's"

    print "Cloning Tenzing Project"
    fetchCode ${tenzing_src_dir} Tenzing ${TENZING_REPO_URL}

fi

if [[ "${build_code}" = "yes"  ]]; then
    #
    #   Packaging Tenzing
    # ======================================================================================================================================

    printHeader "Packaging Tenzing"
    cd ${tenzing_src_dir}/Tenzing/
    mvn clean package -DskipTests  -P${ACTIVE_PROFILE}

else
    echo "Skipping code compilation ..."
fi


echo "Packaging Tenzing Artifacts ..."

mkdir -p ${PACKAGE_DIR}
cd ${PACKAGE_DIR}
rm -r tenzing
rm tenzing.tar.gz
mkdir tenzing

print "Copying Tenzing Files ..."

cp  ${tenzing_src_dir}/Tenzing/RestServices/target/tenzing-services*.war                         ${PACKAGE_DIR}/tenzing/
cp  ${CWD}/tenzing_installer.sh                                                                  ${PACKAGE_DIR}/tenzing/
cp  ${CWD}/sherpa.properties                                                                     ${PACKAGE_DIR}/tenzing/
cp  ${CWD}/log4j.properties                                                                      ${PACKAGE_DIR}/tenzing/


cp  ${CWD}/tunedparams.json                                                                      ${PACKAGE_DIR}/tenzing/
cp  ${CWD}/Mongo/db_installer.sh                                                                 ${PACKAGE_DIR}/tenzing/
cp  ${CWD}/supervisor_setup.sh                                                                   ${PACKAGE_DIR}/tenzing/
cp  ${CWD}/supervisor_init.sh                                                                    ${PACKAGE_DIR}/tenzing/
cp  ${CWD}/tomcat_setup.sh                                                                       ${PACKAGE_DIR}/tenzing/

addBuildNumber ${PACKAGE_DIR}/tenzing

tar -czvf tenzing.tar.gz tenzing/
rm -r tenzing

echo "Done packaging tenzing artifacts ..."

