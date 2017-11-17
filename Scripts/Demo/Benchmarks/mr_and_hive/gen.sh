#!/bin/bash

source ./configurations.sh

if test "$#" -ne 2; then
    echo "Usage: gen.sh terasort|wordcount|join|aggregation|scan <size>"
    exit 1
fi

workload=$1
size=$2
WORKLOAD_DIR=$TEST_DIR/$workload

create_hive_tables() {

cat > ./temp.$$.sql <<EOF
USE DEFAULT;
set hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat;
set hive.stats.autogather=false;
DROP TABLE IF EXISTS rankings;
DROP TABLE IF EXISTS uservisits;
CREATE EXTERNAL TABLE rankings (pageURL STRING, pageRank INT, avgDuration INT) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS SEQUENCEFILE LOCATION '$1/rankings';
CREATE EXTERNAL TABLE uservisits (sourceIP STRING,destURL STRING,visitDate STRING,adRevenue DOUBLE,userAgent STRING,countryCode STRING,languageCode STRING,searchWord STRING,duration INT ) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS SEQUENCEFILE LOCATION '$1/uservisits';
EOF

hive -f ./temp.$$.sql
rm -f ./temp.$$.sql

}


hadoop fs -rm -r $WORKLOAD_DIR/$INPUT_DIR

case $workload in
    "wordcount")
	yarn jar $HADOOP_EXAMPLES_JAR randomtextwriter -D mapreduce.randomtextwriter.totalbytes=$size $WORKLOAD_DIR/$INPUT_DIR
	;;
    "terasort")
	size=`echo "($size / 100)" | bc`
	yarn jar $HADOOP_EXAMPLES_JAR teragen $size $WORKLOAD_DIR/$INPUT_DIR
	;;
    "join" | "scan" | "aggregation")
	uservisits=`echo "($size * 3 / 500 )" | bc`
	pages=`echo "($size * 9 / 12500 )" | bc`
	echo "running sql datagen with p=$pages, v=$uservisits"
	yarn jar ./autogen-5.0-SNAPSHOT-jar-with-dependencies.jar HiBench.DataGen -t hive -p $pages -v $uservisits -o sequence -b $WORKLOAD_DIR -n $INPUT_DIR -m 12 -r 6
	create_hive_tables $WORKLOAD_DIR/$INPUT_DIR
	;;
    *)
	echo "Usage: gen.sh terasort|wordcount|join|aggregation|scan <size>"
	exit 1
esac
