#!/usr/bin/python
import sys
import pymongo
from pymongo import MongoClient
import json

format = "screen" # Valid options: "screen", "-D", "csv" 
workloadID = sys.argv[1]
if len(sys.argv) >= 3:
   format = sys.argv[2]

client = MongoClient() 
db = client.sherpa
coll = db.reports

cursor = coll.find({"workloadID":workloadID}, 
                   {"_id":0, "originator":1, "conf":1, "clientSeqNo":1, "counters":1, "state":1, "jobMetaData":1,
                    "memoryMetric":1, "cpuMetric":1, "latencyMetric":1, "throughputJobLevelMetric":1, "throughputTaskLevelMetric2":1})


defaultValue = 0
bestValue = 1e99
for job in cursor:
     try:
          st = job['jobMetaData']['sherpaTuned']
          if st == 'Yes' or st == 'true':
               if job['state'] == 'SUCCESS' and job['throughputTaskLevelMetric2'] > 0.0 and bestValue > job['throughputTaskLevelMetric2']:
                  if 'CPU_MILLISECONDS_MAP' in job['counters'] and 'CPU_MILLISECONDS_REDUCE' in job['counters']:
                     bestValue = job['counters']['CPU_MILLISECONDS_MAP']['value'] + job['counters']['CPU_MILLISECONDS_REDUCE']['value']
                     bestConfigs = job['conf']
          else:
             defaultValue = job['counters']['CPU_MILLISECONDS_MAP']['value'] + job['counters']['CPU_MILLISECONDS_REDUCE']['value']
     except:
          print "metrics not found"


print "Default CPU metric: ", defaultValue
print "Best CPU metric: ", bestValue
print "Gain: ", 1.0 * defaultValue / bestValue
s = ""
if format == "csv":
     s += '"name", "value"\n'
for confName, val in bestConfigs.iteritems():
     confName = confName.replace('_','.')
     if format == "-D":
          s += " -D " + confName + "=" + val
     if format == "-hiveconf":
          s += " -hiveconf " + confName + "=" + val
     elif format == "csv":
          s += '"' + confName + '",' + val + "\n"
     else:
          s += confName + " = " + val + "\n"
print s

