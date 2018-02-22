#!/bin/bash

source ./configs.sh

for iter in `seq ${sf_low} ${sf_high}`;
do
        co="CPU"
	tag=join-$co-$size-$suffix-$iter

	for i in `seq 1 1` ; do 
	    spark-submit -PSManaged=false -Tag=$tag -sherpaCostObj=$co --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar join.sql
	    hdfs dfs -expunge
	    find / -name \*.sst -exec rm -f {} \;
#	    find /var/log -name \*.log.* -exec rm -f {} \;
	done

	for i in `seq 1 ${iterations}` ; do 
	    spark-submit -PSManaged=true -Tag=$tag -sherpaCostObj=$co --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar join.sql
	    hdfs dfs -expunge
	    find / -name \*.sst -exec rm -f {} \;
#	    find /var/log -name \*.log.* -exec rm -f {} \;
	done
done


