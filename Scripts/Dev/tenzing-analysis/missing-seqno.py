#!/usr/bin/python
import sys
import pymongo
from pymongo import MongoClient

workloadID = sys.argv[1]
print workloadID

client = MongoClient() 
db = client.sherpa
coll = db.reports

cursor = coll.find({"workloadID":workloadID}, 
                   {"_id":0, "originator":1, "conf":1, "clientSeqNo":1, "counters":1, "state":1, "jobMetaData":1})


seqnos = [False for i in range(0,205)]
for job in cursor:
     csn = job['clientSeqNo']
     seqnos[csn-1] = True
     print job['clientSeqNo']
     print job['originator']
     print job['state']
     config = job['conf']
     if 'mapreduce_input_fileinputformat_split_maxsize' in config:
          print "Max split size = ", int(config['mapreduce_input_fileinputformat_split_maxsize']) / 1000000
     print "Map memory MB = ", int(config['mapreduce_map_memory_mb'])
     print "Reduce memory MB = ", int(config['mapreduce_reduce_memory_mb'])
     print "CPU  = ", job['counters']['VCORES_MILLIS_MAPS_TOTAL']['value'] + job['counters']['VCORES_MILLIS_REDUCES_TOTAL']['value']
     print "Memory (GB-s) = ", (job['counters']['MB_MILLIS_MAPS_TOTAL']['value'] + job['counters']['MB_MILLIS_REDUCES_TOTAL']['value']) / 1000000
     print "Latency (s) = ", job['jobMetaData']['latency'] / 1000
     print
#     print job['conf']
#     print job['counters']['VCORES_MILLIS_MAPS_TOTAL']

for i in range(0,205):
     if seqnos[i] == False:
          print i+1
