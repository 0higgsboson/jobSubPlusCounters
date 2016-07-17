#!/bin/sh

# Step 1
# compile TzCtCommon with the command:  mvn clean package -P fatJar
# copy the TzCtCommon*-jar-with-dependencies.jar file to a dir and set the following path to point to it

TZCTCOMMON_JAR=/opt/sherpa/lib/TzCtCommon-jar-with-dependencies.jar


# Step 2
# Bring down Tenzing services manually


# Step 3
# Run the script
echo "Launching 200 dummy jobs ..."
java -cp /opt/sherpa/lib/TzCtCommon-jar-with-dependencies.jar com.sherpa.common.tests.ca.CALoadSimulator 5 20 5 20 10

echo "Waiting for CA to accept all jobs requests ..."
sleep 40


count="$(ls /opt/sherpa/ClientAgent/configs-data/ | wc -l)"
echo "Saved Configs Count: ${count}"
if [ "$count" -ne 200 ]; then
    echo "Error: Test failed, check number of files at /opt/sherpa/ClientAgent/configs-data/  ..."
    exit 1
else
    echo "All configs successfully saved to disk ..."
fi


# Step 4
# Bring up Tenzing services manually

echo "Bring up Tenzing service ..."
sleep 120

count="$(ls /opt/sherpa/ClientAgent/configs-data/ | wc -l)"
if [ "$count" -ne 0 ]; then
    echo "Error: Test failed, check number of files at /opt/sherpa/ClientAgent/configs-data/  ..."
    exit 1
else
    echo "All configs successfully sent to Tenzing ..."
    echo "Test successfull ..."
fi
