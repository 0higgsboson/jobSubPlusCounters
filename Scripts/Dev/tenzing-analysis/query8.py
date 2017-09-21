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
                    "memoryMetric":1, "cpuMetric":1, "latencyMetric":1, "throughputJobLevelMetric":1, "throughputTaskLevelMetric":1, "throughputTaskLevelMetric2":1})



for job in cursor:
     print "---------------------------------------------------------------------"
     print "ClientSeqNo: ", job['clientSeqNo']
     print "Originator: ", job['originator']
     print "State: ", job['state']
     if job['state'] != 'SUCCESS':
          continue
     if 'conf' in job:
          config = job['conf']
          print config
          #     if 'mapreduce_input_fileinputformat_split_maxsize' in config:
          #          print "Max split size = ", int(config['mapreduce_input_fileinputformat_split_maxsize']) / 1000000
          # print "Map memory MB = ", int(config['mapreduce_map_memory_mb'])
          # print "Reduce memory MB = ", int(config['mapreduce_reduce_memory_mb'])
          # print "Reducers = ", int(config['mapreduce_job_reduces'])
     else:
          print "Configs missing!"
     if 'counters' in job:
#          print job['counters']
#          print json.dumps(job['counters'], indent=4)
          cpu = None
          mem = None
          latency = None
          if 'CPU_MILLISECONDS_MAP' in job['counters'] and 'CPU_MILLISECONDS_REDUCE' in job['counters']:
               cpu = job['counters']['CPU_MILLISECONDS_MAP']['value'] + job['counters']['CPU_MILLISECONDS_REDUCE']['value']
               print "CPU  = ", cpu
          else:
               if 'CPU_MILLISECONDS' in job['counters']:
                    print "CPU = ", job['counters']['CPU_MILLISECONDS']['value']
          if 'VCORES_MILLIS_MAPS_TOTAL' in job['counters'] and 'VCORES_MILLIS_REDUCES_TOTAL' in job['counters']:
               print "VCores  = ", job['counters']['VCORES_MILLIS_MAPS_TOTAL']['value'] + job['counters']['VCORES_MILLIS_REDUCES_TOTAL']['value']
          if 'MB_MILLIS_MAPS_TOTAL' in job['counters'] and 'MB_MILLIS_REDUCES_TOTAL' in job['counters']:
               mem = (job['counters']['MB_MILLIS_MAPS_TOTAL']['value'] + job['counters']['MB_MILLIS_REDUCES_TOTAL']['value']) / 1000000
               print "Memory (GB-s) = ", mem
          else:
               if 'Memory_Bytes_Seconds' in job['counters']:
                    print "Memory (GB-s) = ", job['counters']['Memory_Bytes_Seconds']['value'] / 1000000
          if 'Latency' in job['counters']:
               latency = job['counters']['Latency']['value']
               print "Latency in counters: ", latency
          if cpu and mem and latency:
               print "Throughput Metric = ", cpu * mem / latency
#     if 'jobMetaData' in job:
#          if 'latency' in job['jobMetaData']:
#               print "Latency in jobMetaData (s) = ", job['jobMetaData']['latency'] / 1000
          print "Sherpa Tuned: ", job['jobMetaData']['sherpaTuned']
          print job['jobMetaData']
     print

     print job

     try:
          print "Metrics:"
          print job['memoryMetric']
          print job['cpuMetric']
          print job['latencyMetric']
          print job['throughputJobLevelMetric']
          print job['throughputTaskLevelMetric']
          print job['throughputTaskLevelMetric2']
     except:
          print "metrics not found"

#     print job['conf']
#     print job['counters']['VCORES_MILLIS_MAPS_TOTAL']
