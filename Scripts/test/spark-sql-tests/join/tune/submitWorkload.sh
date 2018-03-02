
submit_workload(){
  sqljar=/root/jobsubplus/jobSubPlusCounters/Scripts/Dev/spark-sql-tests/target/RunSQL-1.1-SNAPSHOT-jar-with-dependencies.jar

  # echo context=$1 tag=$tag date PSManaged=$2 sqlFile=$3

  numRunsCompleted=$(( numRunsCompleted +1 ))

  echo start date = $started now = `date '+%Y-%m-%d %H:%M:%S'`  numRunsCompleted = $numRunsCompleted total Runs = $numRuns
  # return

  echo spark-submit -PSManaged=$2 -Tag=$tag -sherpaCostObj=$co --class com.sherpa.RunSQL.RunSQL $sqljar $3 
  spark-submit -PSManaged=$2 -Tag=$tag -sherpaCostObj=$co --class com.sherpa.RunSQL.RunSQL $sqljar $3

  if [ "$3" == "join.sql" ]; then
    echo hadoop fs -rm -r -skipTrash /user/root/SQLTest/Output/RUJ
    hadoop fs -rm -r -skipTrash /user/root/SQLTest/Output/RUJ
  fi
  if [ "$3" == "scan.sql" ]; then
    echo hadoop fs -rm -r -skipTrash /user/root/SQLTest/Output/uservisits_aggre
    hadoop fs -rm -r -skipTrash /user/root/SQLTest/Output/uservisits_aggre
  fi
  if [ "$3" == "aggregation.sql" ]; then
    echo hadoop fs -rm -r -skipTrash /user/root/SQLTest/Output/uservisits_scan_copy
    hadoop fs -rm -r -skipTrash /user/root/SQLTest/Output/uservisits_scan_copy
  fi

  find / -name \*.sst -exec rm -f {} \;

}

