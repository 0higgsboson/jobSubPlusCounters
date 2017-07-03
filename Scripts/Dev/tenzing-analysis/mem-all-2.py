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
#          print job['memoryMetric'], job['counters']['Memory_Bytes_Seconds']/60000000.0, (job['counters']['MB_MILLIS_MAPS_TOTAL']['value'] + job['counters']['MB_MILLIS_REDUCES_TOTAL']['value']) / 60000000.0
          print job['memoryMetric'], (job['counters']['MB_MILLIS_MAPS_TOTAL']['value'] + job['counters']['MB_MILLIS_REDUCES_TOTAL']['value']) / 60000000.0
     except:
          print "metrics not found"

#     print job['conf']
#     print job['counters']['VCORES_MILLIS_MAPS_TOTAL']
