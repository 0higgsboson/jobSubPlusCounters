#!/bin/bash

#
# Installs MR & Hive Clients Jars
#

# Write permissions required on following dir for current user, read permissions should be granted to Hadoop user
INSTALL_DIR=/opt/sherpa/lib/



mkdir -p ${INSTALL_DIR}
rm    -r ${INSTALL_DIR}/*

echo "Deploying MR Client ..."
cp  hadoop-mapreduce-client-core*.jar             ${INSTALL_DIR}/
cp  TzCtCommon*jar-with-dependencies.jar          ${INSTALL_DIR}/
cp  sherpa.properties                             "/opt/sherpa.properties"
echo "Done Deploying MR Client ..."


echo "Deploying Hive Client ..."
cp  hive-cli*.jar             ${INSTALL_DIR}/
cp  hive-exec*.jar            ${INSTALL_DIR}/
echo "Done Deploying Hive Client ..."

