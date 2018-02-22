#!/bin/bash

source ./configs.sh

sleep 600;

for co in "CPU"; # "Memory" "Latency" "CPU" ;
do
    tag=join-$co-$size-$suffix

    for i in `seq 1 5` ; do 
	spark-submit -PSManaged=false -Tag=$tag -sherpaCostObj=$co --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar join.sql
        sleep 40;
    done


    sleep 240;


    for i in `seq 1 200` ; do 
	spark-submit -PSManaged=true -Tag=$tag -sherpaCostObj=$co --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar join.sql
        if (($i%10 == 0)); then
          sleep 120;
          continue;
        fi
        sleep 40;
    done


    sleep 240;


    for i in `seq 1 5` ; do
        spark-submit -PSManaged=false -Tag=$tag -sherpaCostObj=$co --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar join.sql
        sleep 40;
    done

done
