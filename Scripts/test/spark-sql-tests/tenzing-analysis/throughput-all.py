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



for job in cursor:
     try:
          print job['throughputTaskLevelMetric']
     except:
          print "metrics not found"

#     print job['conf']
#     print job['counters']['VCORES_MILLIS_MAPS_TOTAL']
