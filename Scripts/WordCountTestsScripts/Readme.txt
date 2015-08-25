
To set up the code on a new machine, Here is what you need to run it

 1. Define configuration file, there is a sample configuration file provided with this project, named rest.conf, change configurations as per your requirements and place it in a dir

 2. Change configuration file path in Class com.performancesherpa.joblauncher.WorkloadDriver, find under configurationBasedRun method.

 3. Compile and build a jar and run it.


 Here is the sample configuration and commands to run on master node:

 Config file path: /home/akhtar_mdin/rest.conf

 /usr/lib/jvm/java-7-oracle-cloudera/jre/bin/java -Dlog4j.configuration=file:///root/tunecore2/tunecore/log4j.properties -jar
 /root/tunecore2/tunecore/target/tunecore-1.0-SNAPSHOT-jar-with-dependencies.jar sudo
 yarn jar /opt/cloudera/parcels/CDH-5.4.4-1.cdh5.4.4.p0.4/lib/hadoop/share/hadoop/mapreduce2/hadoop-mapreduce-examples-2.6.0-cdh5.4.4.jar pi 16 10

its format is:
java -jar jarPath yarnCommand 

 4. find output files under storage dir defined in configuration file




To run the Word Count Workloads
-------------------------------

Note:
All scripts assume that path is reletive to root of the project
You need to run all the scripts from project root dir e.g.

./Scripts/WordCountTestsScripts/printCounters.sh


To use hbalse client, use the following command and follow the usage instrcutions
/usr/lib/jvm/java-7-oracle-cloudera/jre/bin/java -Dlog4j.configuration=file:///root/SP/log4j.properties -cp core/target/core-1.0-SNAPSHOT.jar:tunecore/
target/tunecore-1.0-SNAPSHOT-jar-with-dependencies.jar com.sherpa.core.utils.Driver


For every workload there is a run script provided, for example to run MR Small workload run the following command
./Scripts/WordCountTestsScripts/mr_small.sh

and so on.



To create Hive tables for the very first time, use the createTables.sh script. This script assumes that test data is placed under /root/TestsData/ as follows:
/root/TestsData/large
/root/TestsData/normal
/root/TestsData/small










 
