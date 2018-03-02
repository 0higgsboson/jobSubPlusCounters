#!/bin/bash

findSuccessfulRunData() {
  echo findSuccessfulRunData $1 `date '+%Y-%m-%d %H:%M:%S'`
  ./query9.py $1-1 > log/$1-1.log
  ./query9.py $1-2 > log/$1-2.log
  ./query9.py $1-3 > log/$1-3.log
  ./query9.py $1-4 > log/$1-4.log
  ./query9.py $1-5 > log/$1-5.log

  cat log/$1-*.log | grep SUCCESS > log/$1-successfulTzRuns.log
  cat log/$1-*.log | grep Client | grep SUCCESS > log/$1-successfulClientRuns.log
}

generateConfFiles() {
  echo generateConfFiles $1 `date '+%Y-%m-%d %H:%M:%S'`
  ./bestconfig.py $1-1 -D > conf/$1-1.conf
  ./bestconfig.py $1-2 -D > conf/$1-2.conf
  ./bestconfig.py $1-3 -D > conf/$1-3.conf
  ./bestconfig.py $1-4 -D > conf/$1-4.conf
  ./bestconfig.py $1-5 -D > conf/$1-5.conf
}

findBestTenzingIds(){
  echo printing top Tenzing IDs $1 > log/$1-Tz-top3.log
  sort -k7 -n log/$1-successfulTzRuns.log | head -3 >> log/$1-Tz-top3.log

  echo printing top Client Generated Tenzing IDs $1 > log/$1-CA-top3.log
  sort -k7 -n log/$1-successfulClientRuns.log | head -3 >> log/$1-CA-top3.log
}

genPerfDataAndConfFiles(){
  findSuccessfulRunData $1
  findBestTenzingIds $1

  generateConfFiles $1
}

printResults(){
  echo printing log files
  ls -altr log/
  echo printing conf files
  ls -altr conf/
  cat log/*top3.log
}

rm log/*
rm conf/*

genPerfDataAndConfFiles "aggregation-CPU-5GB-03-01-2018-007"
genPerfDataAndConfFiles "join-CPU-5GB-03-01-2018-007"
genPerfDataAndConfFiles "scan-CPU-5GB-03-01-2018-007"

printResults

