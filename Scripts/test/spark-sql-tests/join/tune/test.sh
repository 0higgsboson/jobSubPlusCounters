#!/bin/bash

source ./configs.sh

sqljar=/root/jobsubplus/jobSubPlusCounters/Scripts/Dev/spark-sql-tests/target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar

tag=join-$co-$size-$suffix-01

spark-submit -PSManaged=false -Tag=$tag -sherpaCostObj=$co --class com.sherpa.RunSQL.RunSQL $sqljar join.sql

