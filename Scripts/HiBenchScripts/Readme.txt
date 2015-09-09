Before you run the scripts, please make sure you have defined the following settings:

Step 1)
99-user_defined_properties.conf
--------------------------------
Change the following settings as per your environment

hibench.hadoop.home             /opt/cloudera/parcels/CDH-5.4.4-1.cdh5.4.4.p0.4/lib/hadoop/

hibench.spark.home              /opt/cloudera/parcels/CDH-5.4.4-1.cdh5.4.4.p0.4/lib/spark/

hibench.hdfs.master             hdfs://cera-cluster-057-master.c.marine-equinox-95405.internal:8020/

hibench.spark.master            yarn-client

hibench.hadoop.version     hadoop2

hibench.hadoop.release     cdh5

hibench.spark.version          spark1.3


Step 2)
run.sh
-------------------------------
Define CDH Version
CDH_VERSION=CDH-5.4.5-1.cdh5.4.5.p0.7


Step 3)
run setup.sh, it will clone, build the project and will copy the configurations
./setup.sh
You need to run it only once

Step 4)
run run.sh, it will apply fixes and will run the benchmark tests
./run.sh


Notes:
run-all.sh is a script taken from HiBench project, it includes hive table drop statements

Assumptions:
Please make sure JAVA_HOME is defined
Please makse sure numPy is installed on all the hosts in the cluster


