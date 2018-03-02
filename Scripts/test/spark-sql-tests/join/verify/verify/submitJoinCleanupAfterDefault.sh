#!/bin/sh
/opt/cloudera/parcels/SPARK2-2.1.0.cloudera2-1.cdh5.7.0.p0.171658/lib/spark2/bin/spark-submit --class com.sherpa.RunSQL.RunSQL target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar joinXXX.sql;
hadoop fs -rm -r -skipTrash /user/root/SQLTest/Output/RUJXXX;
find / -name \*.sst -exec rm -f {} \;

