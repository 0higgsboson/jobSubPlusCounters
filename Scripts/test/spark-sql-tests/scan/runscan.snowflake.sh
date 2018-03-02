#!/bin/bash

source ./configs.sh

for iter in `seq ${sf_low} ${sf_high}`;
do
    for co in "Memory" "Latency" "CPU" ;
    do
	tag=scan-$co-$size-$suffix-$iter

	for i in `seq 1 1` ; do 
	    spark-submit -PSManaged=false -Tag=$tag -sherpaCostObj=$co --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar scan.sql
	    hdfs dfs -expunge
	done

	for i in `seq 1 ${iterations}` ; do 
	    spark-submit -PSManaged=true -Tag=$tag -sherpaCostObj=$co --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar scan.sql
	    hdfs dfs -expunge
	done
    done
done


