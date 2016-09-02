#!/usr/bin/python
import sys
import pymongo
from pymongo import MongoClient

workloadID = sys.argv[1]
print workloadID

client = MongoClient() 
db = client.sherpa
coll = db.reports

job = coll.find_one({"workloadID":workloadID, "originator":"Client"}, 
                   {"_id":0, "originator":1, "conf":1, "clientSeqNo":1, "counters":1, "state":1, "jobMetaData":1})



print job['clientSeqNo']
print job['originator']
print job['state']
config = job['conf']
print config
#     if 'mapreduce_input_fileinputformat_split_maxsize' in config:
#          print "Max split size = ", int(config['mapreduce_input_fileinputformat_split_maxsize']) / 1000000
print "Map memory MB = ", int(config['mapreduce_map_memory_mb'])
print "Reduce memory MB = ", int(config['mapreduce_reduce_memory_mb'])
print "Reducers = ", int(config['mapreduce_job_reduces'])
#     print config
if 'counters' in job:
     if 'CPU_MILLISECONDS_MAP' in job['counters'] and 'CPU_MILLISECONDS_REDUCE' in job['counters']:
          print "CPU  = ", job['counters']['CPU_MILLISECONDS_MAP']['value'] + job['counters']['CPU_MILLISECONDS_REDUCE']['value']
     if 'VCORES_MILLIS_MAPS_TOTAL' in job['counters'] and 'VCORES_MILLIS_REDUCES_TOTAL' in job['counters']:
          print "VCores  = ", job['counters']['VCORES_MILLIS_MAPS_TOTAL']['value'] + job['counters']['VCORES_MILLIS_REDUCES_TOTAL']['value']
     if 'MB_MILLIS_MAPS_TOTAL' in job['counters'] and 'MB_MILLIS_REDUCES_TOTAL' in job['counters']:
          print "Memory (GB-s) = ", (job['counters']['MB_MILLIS_MAPS_TOTAL']['value'] + job['counters']['MB_MILLIS_REDUCES_TOTAL']['value']) / 1000000
if 'jobMetaData' in job:
     if 'latency' in job['jobMetaData']:
          print "Latency (s) = ", job['jobMetaData']['latency'] / 1000
print
#     print job['conf']
#     print job['counters']['VCORES_MILLIS_MAPS_TOTAL']
