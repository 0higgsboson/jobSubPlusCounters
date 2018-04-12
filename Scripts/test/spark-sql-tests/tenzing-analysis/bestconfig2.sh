#!/bin/bash

echo "Printing work load id's : "
python list-workloadids.py 

echo "Enter the work load id (without iteration number): "
read workloadid
echo $workloadid

findSuccessfulRunData() {
  echo findSuccessfulRunData $workloadid `date '+%Y-%m-%d %H:%M:%S'`
  ./query9.py $workloadid-1 > log3/$workloadid-1-all.log
  ./query9.py $workloadid-2 > log3/$workloadid-2-all.log
  ./query9.py $workloadid-3 > log3/$workloadid-3-all.log
  ./query9.py $workloadid-4 > log3/$workloadid-4-all.log
  ./query9.py $workloadid-5 > log3/$workloadid-5-all.log

  cat log3/$workloadid-*-all.log | grep Tenzing | grep SUCCESS > log3/$workloadid-successfulTzRuns.log
  cat log3/$workloadid-*-all.log | grep Client | grep SUCCESS > log3/$workloadid-successfulClientRuns.log
}

findBestTenzingIds(){
  if [[ $workloadid = *"CPU"* ]]; then
    echo printing top Tenzing IDs for  $workloadid > log3/$workloadid-Tz-CPU-top3.log
    echo -e "ClientSeqNo\tOriginator\tState\tSherpaTuned\tLatency\tMemory\tCPU" >> log3/$workloadid-Tz-CPU-top3.log
    sort -k7 -n log3/$workloadid-successfulTzRuns.log | head -3 >> log3/$workloadid-Tz-CPU-top3.log
    cat log3/$workloadid-Tz-CPU-top3.log
    echo "+++++++++++++++"
    echo "Getting top Tenzing ID"
    Top_Tz_id="$(awk 'NR == 3 {print $1}' log3/$workloadid-Tz-CPU-top3.log)"
    echo "${Top_Tz_id}"

    if [ -z "$Top_Tz_id" ]; then
      echo "There are no successfull tenzing id's for $workloadid "
      exit 1
    else
      echo "Finding top tenzing id iteration file"
      #Top_Tz_File="$(find log3/$workloadid-*.log -name "$Top_Tz_id")"
      Top_Tz_File="$(egrep -n $Top_Tz_id log3/$workloadid-*-all.log | cut -d ":" -f1)"
      echo "${Top_Tz_File}"

      echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    fi

    #echo printing top Client Generated Tenzing IDs $workloadid > log3/$workloadid-CA-top3.log
    #echo -e "ClientSeqNo\tOriginator\tState\tSherpaTuned\tLatency\tMemory\tCPU" >> log3/$workloadid-CA-top3.log
    #sort -k7 -n log3/$workloadid-successfulClientRuns.log | head -3 >> log3/$workloadid-CA-top3.log
    #cat log3/$workloadid-CA-top3.log
    #echo "++++++++++++++++++++"

    #echo "Getting Top Client Agent Tenzing ID"
    #Top_CA_Tz_id="$(awk 'NR == 3 {print $1}' log3/$workloadid-CA-top3.log)"
    #echo "${Top_CA_Tz_id}"

    #echo "Finding top Client Agent Tenzing id iteration file"
    #Top_CA_Tz_File="$(egrep -n $Top_CA_Tz_id log3/$workloadid-*-all.log | cut -d ":" -f1)"
    #echo "${Top_CA_Tz_File}"


  elif [[ $workloadid  = *"Memory"* ]]; then
    echo printing top Tenzing IDs for $workloadid > log3/$workloadid-Tz-Memory-top3.log
    echo -e "ClientSeqNo\tOriginator\tState\tSherpaTuned\tLatency\tMemory\tCPU" >> log3/$workloadid-Tz-Memory-top3.log
    sort -k6 -n log3/$workloadid-successfulTzRuns.log | head -3 >> log3/$workloadid-Tz-Memory-top3.log
    cat log3/$workloadid-Tz-Memory-top3.log
    echo "+++++++++++++++"
    echo "Getting top Tenzing ID"
    Top_Tz_id="$(awk 'NR == 3 {print $1}' log3/$workloadid-Tz-Memory-top3.log)"
    echo "${Top_Tz_id}"

    if [ -z "$Top_Tz_id" ]; then
      echo "There are no successfull tenzing id's"
      exit 1
    else
      echo "Finding top tenzing id iteration file"
      Top_Tz_File="$(egrep -n $Top_Tz_id log3/$workloadid-*-all.log | cut -d ":" -f1)"
      echo "${Top_Tz_File}"

      echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    fi

  elif [[ $workloadid  = *"Latency"* ]]; then
    echo printing top Tenzing IDs for $workloadid > log3/$workloadid-Tz-Latency-top3.log
    echo -e "ClientSeqNo\tOriginator\tState\tSherpaTuned\tLatency\tMemory\tCPU" >> log3/$workloadid-Tz-Latency-top3.log
    sort -k6 -n log3/$workloadid-successfulTzRuns.log | head -3 >> log3/$workloadid-Tz-Latency-top3.log
    cat log3/$workloadid-Tz-Latency-top3.log
    echo "+++++++++++++++"
    echo "Getting top Tenzing ID"
    Top_Tz_id="$(awk 'NR == 3 {print $1}' log3/$workloadid-Tz-Latency-top3.log)"
    echo "${Top_Tz_id}"

    if [ -z "$Top_Tz_id" ]; then
      echo "There are no successfull tenzing id's for $workloadid "
      exit 1
    else
      echo "Finding top tenzing id iteration file"
      Top_Tz_File="$(egrep -n $Top_Tz_id log3/$workloadid-*-all.log | cut -d ":" -f1)"
      echo "${Top_Tz_File}"

      echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    fi

  else
    echo "Please enter the correct file name"
  fi

}

generateConfFiles() {
  echo generateConfFiles $workloadid `date '+%Y-%m-%d %H:%M:%S'`
  ./bestconfig.py $workloadid-1 -D > conf3/$workloadid-1.conf
  ./bestconfig.py $workloadid-2 -D > conf3/$workloadid-2.conf
  ./bestconfig.py $workloadid-3 -D > conf3/$workloadid-3.conf
  ./bestconfig.py $workloadid-4 -D > conf3/$workloadid-4.conf
  ./bestconfig.py $workloadid-5 -D > conf3/$workloadid-5.conf


  if [[ $workloadid = *"CPU"* ]]; then
    echo "Printing Best Configuration for CPU's Top Tenzing id : "
    Best_TZ_conf_file="$(egrep -n $Top_Tz_id conf3/$workloadid-*.conf | cut -d ":" -f1)"
    if [ -z "$Best_TZ_conf_file" ]; then
      echo "There is no successfull tenzing matching configuration file"
      exit
    else  
      echo "${Best_TZ_conf_file}"
      cat $Best_TZ_conf_file
    fi
  

  elif [[ $workloadid  = *"Memory"* ]]; then
    echo "Printing Best Configuration for Memory's Top Tenzing id : "
    Best_TZ_conf_file="$(egrep -n $Top_Tz_id conf3/$workloadid-*.conf | cut -d ":" -f1)"
    if [ -z "$Best_TZ_conf_file" ]; then
      echo "There is no successfull tenzing matching configuration file"
      exit
    else
      echo "${Best_TZ_conf_file}"
      cat $Best_TZ_conf_file
    fi


  elif [[ $workloadid  = *"Latency"* ]]; then 
    echo "Printing Best Configuration for Latency's Top Tenzing id : "
    Best_TZ_conf_file="$(egrep -n $Top_Tz_id conf3/$workloadid-*.conf | cut -d ":" -f1)"
    if [ -z "$Best_TZ_conf_file" ]; then
      echo "There is no successfull tenzing matching configuration file"
      exit
    else
      echo "${Best_TZ_conf_file}"
      cat $Best_TZ_conf_file
    fi

  else
    exit 1;
  
  fi

}


joincleanupaftertuned() {
  SPARK_SUB=/opt/cloudera/parcels/CDH-5.14.0-1.cdh5.14.0.p0.24/bin/spark-submit
  best_config=`sed -n '2p' < $Best_TZ_conf_file`
  command=$SPARK_SUB$best_config
  echo -e "\n\nPrinting final best configuration command for $workloadid : \n"
  echo $command
  
}

floodSparkWJoin() {
echo "Executing flood spark W joing"

source configs.sh

while true; do

  yarn application -list > tmp.txt
  sparkAppCount=$(cat tmp.txt | grep SPARK | wc -l)
  echo count is $sparkAppCount num parallel jobs is $numParallelJobs i = $i

  if (($sparkAppCount < $numParallelJobs)); then
    echo Submitting job wait for $sleepWaitForJobSubmission seconds for job to be submitted before polling

    cp join.sql todelete/join$i.sql
    sed -i "s/RUJ/RUJ$i/g" todelete/join$i.sql

    cp submitJoinCleanupAfter.sh todelete/submitJoinCleanupAfter$i.sh
    sed -i "s/XXX/$i/g" todelete/submitJoinCleanupAfter$i.sh

    nohup todelete/submitJoinCleanupAfter$i.sh &
    sleep $sleepWaitForJobSubmission

    i=$[$i+1]

    if (($i >= $numItersMax)); then
      break;
    fi
  fi

  date
  sleep $sleepSeconds

done;


sleep $sleepBetweenRuns


i=0

while true; do

  yarn application -list > tmp.txt
  sparkAppCount=$(cat tmp.txt | grep SPARK | wc -l)
  echo count is $sparkAppCount num parallel jobs is $numParallelJobs i = $i

  if (($sparkAppCount < $numParallelJobs)); then

    echo Submitting job wait for $sleepWaitForJobSubmission seconds for job to be submitted before polling

    cp join.sql todelete/join$i.sql
    sed -i "s/RUJ/RUJ$i/g" todelete/join$i.sql
    
    cp submitJoinCleanupAfterTuned.sh todelete/submitJoinCleanupAfterTuned$i.sh
    sed -i "s/XXX/$i/g" todelete/submitJoinCleanupAfterTuned$i.sh

    nohup todelete/submitJoinCleanupAfterTuned$i.sh &
    sleep $sleepWaitForJobSubmission

    i=$[$i+1]
  
    if (($i >= $numItersMax)); then
      break;
    fi
  fi

  date
  sleep $sleepSeconds

done;

# mv submitJoinCleanupAfter* todelete/
# mv join*sql todelete
# cp todelete/join.sql .
mv floodSparkWJoin.*.log todelete/

exit;

}

genPerfDataAndConfFiles(){
  findSuccessfulRunData $workloadid
  findBestTenzingIds $workloadid
  generateConfFiles $workloadid
  joincleanupaftertuned $workloadid
#  floodSparkWJoin $workloadid
}

mkdir -p log3
mkdir -p conf3

rm log3/*
rm conf3/*

genPerfDataAndConfFiles $workloadid

