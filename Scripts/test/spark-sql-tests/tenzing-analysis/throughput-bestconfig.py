#!/usr/bin/python
import sys
import pymongo
from pymongo import MongoClient
import json

workloadID = sys.argv[1]
print workloadID

client = MongoClient() 
db = client.sherpa
coll = db.reports

cursor = coll.find({"workloadID":workloadID}, 
                   {"_id":0, "originator":1, "conf":1, "clientSeqNo":1, "counters":1, "state":1, "jobMetaData":1,
                    "memoryMetric":1, "cpuMetric":1, "latencyMetric":1, "throughputJobLevelMetric":1, "throughputTaskLevelMetric":1})


defaultValue = 0
bestValue = 1e99
for job in cursor:
     try:
          st = job['jobMetaData']['sherpaTuned']
          if st == 'Yes' or st == 'true':
               bestValue = min(bestValue, job['throughputTaskLevelMetric'])
          else:
               defaultValue = job['throughputTaskLevelMetric']
     except:
          print "metrics not found"


print "Best throughput metric: ", bestValue
print "Default throughput metric: ", defaultValue
print "Gain: ", defaultValue / bestValue
