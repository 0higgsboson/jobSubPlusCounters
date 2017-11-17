#!/bin/bash

if test "$#" -ne 4; then
    echo "Usage: run1.sh <workload> <tag> <cost_objective> <PSManaged>"
    exit 1
fi

source ./configurations.sh

workload=$1
tag=$2
co=$3
psmanaged=$4

echo "Workload: $workload Tag: $tag Cost Objective: $co Sherpa_Managed: $psmanaged"

WORKLOAD_DIR=$TEST_DIR/$workload

input_dir=$WORKLOAD_DIR/$INPUT_DIR
output_dir=$WORKLOAD_DIR/$OUTPUT_DIR


hadoop fs -rm -r $output_dir

case $workload in
    "wordcount")
	yarn jar $HADOOP_EXAMPLES_JAR wordcount -D Tag=$tag -D PSManaged=$psmanaged -D SherpaCostObj=$co $input_dir $output_dir
	;;
    "terasort")
	yarn jar $HADOOP_EXAMPLES_JAR terasort  -D Tag=$tag -D PSManaged=$psmanaged -D SherpaCostObj=$co -D mapreduce.terasort.simplepartitioner=true $input_dir $output_dir
	;;
    "join")
	cat > ./join.$$.sql <<EOF
         USE DEFAULT;
         set hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat;
         set hive.stats.autogather=false;
         DROP TABLE IF EXISTS rankings_uservisits_join;
         CREATE EXTERNAL TABLE rankings_uservisits_join ( sourceIP STRING, avgPageRank DOUBLE, totalRevenue DOUBLE) STORED AS SEQUENCEFILE LOCATION '$output_dir/rankings_uservisits_join';
         INSERT OVERWRITE TABLE rankings_uservisits_join SELECT sourceIP, avg(pageRank), sum(adRevenue) as totalRevenue FROM rankings R JOIN (SELECT sourceIP, destURL, adRevenue FROM uservisits UV WHERE (datediff(UV.visitDate, '1999-01-01')>=0 AND datediff(UV.visitDate, '2000-01-01')<=0)) NUV ON (R.pageURL = NUV.destURL) group by sourceIP order by totalRevenue DESC;
EOF
	hive -hiveconf Tag=$tag -hiveconf PSManaged=$psmanaged -hiveconf SherpaCostObj=$co -f ./join.$$.sql
	rm ./join.$$.sql
	;;
    "aggregation")
	cat > ./agg.$$.sql <<EOF
        USE DEFAULT;
        set hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat;
        set hive.stats.autogather=false;
        DROP TABLE IF EXISTS uservisits_aggre;
        CREATE EXTERNAL TABLE uservisits_aggre ( sourceIP STRING, sumAdRevenue DOUBLE) STORED AS SEQUENCEFILE LOCATION '$output_dir/uservisits_aggre';
        INSERT OVERWRITE TABLE uservisits_aggre SELECT sourceIP, SUM(adRevenue) FROM uservisits GROUP BY sourceIP;
EOF
	hive -hiveconf Tag=$tag -hiveconf PSManaged=$psmanaged -hiveconf SherpaCostObj=$co -f ./agg.$$.sql
	rm ./agg.$$.sql
	;;
    "scan")
	cat > ./scan.$$.sql <<EOF
        USE DEFAULT;
        set hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat;
        set hive.stats.autogather=false;
        DROP TABLE IF EXISTS uservisits_copy;
        CREATE EXTERNAL TABLE uservisits_copy (sourceIP STRING,destURL STRING,visitDate STRING,adRevenue DOUBLE,userAgent STRING,countryCode STRING,languageCode STRING,searchWord STRING,duration INT ) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS SEQUENCEFILE LOCATION '$output_dir/uservisits_copy';
        INSERT OVERWRITE TABLE uservisits_copy SELECT * FROM uservisits;
EOF
        hive -hiveconf Tag=$tag -hiveconf PSManaged=$psmanaged -hiveconf SherpaCostObj=$co -f ./scan.$$.sql
	rm ./scan.$$.sql
	;;
    *)
	echo "Unsupported workload type $workload"
	exit 1
	;;
esac
