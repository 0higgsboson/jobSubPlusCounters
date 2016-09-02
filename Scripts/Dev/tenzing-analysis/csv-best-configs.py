#!/usr/bin/python
import pymongo
from pymongo import MongoClient
import collections

workloads = ["terasort", "sort", "aggregation", "join", "wordcount"]
dataSizes = ["tiny", "small", "large"]
costObjectives = ["Memory"]
suffix = "08-18-2016"

client = MongoClient() 
db = client.sherpa
coll = db.reports
tzcoll = db.tenzings
cursor = coll.find({},
                    {"_id":0, "workloadID":1, "jobMetaData.tag":1
                    })

s = set()
csvtable = collections.OrderedDict()
firstLine = True
for job in cursor:
     if job['workloadID'] in s:
          continue
     elif job['jobMetaData']['tag'] == 'NA':
          continue
     else:
          s.add(job['workloadID'])
#          print job['workloadID'], "....", job['jobMetaData']['tag']
          workloadID = job['workloadID']
          tag = job['jobMetaData']['tag']
          tz = tzcoll.find_one({"workloadID":workloadID})
          if 'bestConfig' in tz:
               if firstLine:
                    csvtable['0'] = collections.OrderedDict()
                    csvtable['0']['workloadID'] = 'workloadID'
                    csvtable['0']['Tag'] = 'Tag'
               csvtable[workloadID] = collections.OrderedDict()
               csvtable[workloadID]['workloadID'] = workloadID
               csvtable[workloadID]['Tag'] = tag
               bestConfig = tz['bestConfig']['tunedParams']
               for confName, confValue in bestConfig.iteritems():
                    if firstLine:
                         csvtable['0'][confName] = confName
                    csvtable[workloadID][confName] = confValue['value']
               if firstLine:
                    csvtable['0']['Cost'] = "Cost"
                    csvtable['0']['CostObjective'] = "CostObjective"
                    csvtable['0']['Memory'] = "Memory"
                    csvtable['0']['CPU'] = "CPU"
                    csvtable['0']['Latency'] = "Latency"
                    csvtable['0']['Default_Memory'] = "Default_Memory"
                    csvtable['0']['Default_CPU'] = "Default_CPU"
                    csvtable['0']['Default_Latency'] = "Default_Latency"
                    firstLine = False
               csvtable[workloadID]['Cost'] = tz['bestConfig']['cost']
               csvtable[workloadID]['CostObjective'] = tz['costObjective']
               job = tz['bestConfig']
               if 'counters' in job:
                    if 'CPU_MILLISECONDS_MAP' in job['counters'] and 'CPU_MILLISECONDS_REDUCE' in job['counters']:
                         csvtable[workloadID]['CPU'] = job['counters']['CPU_MILLISECONDS_MAP']['value'] + job['counters']['CPU_MILLISECONDS_REDUCE']['value']
                    if 'MB_MILLIS_MAPS_TOTAL' in job['counters'] and 'MB_MILLIS_REDUCES_TOTAL' in job['counters']:
                         csvtable[workloadID]['Memory'] = (job['counters']['MB_MILLIS_MAPS_TOTAL']['value'] + job['counters']['MB_MILLIS_REDUCES_TOTAL']['value']) / 1000000.00
                    if 'jobMetaData' in job:
                         if 'latency' in job['jobMetaData']:
                              csvtable[workloadID]['Latency'] = job['jobMetaData']['latency'] / 1000.00
               defaultjob = coll.find_one({"workloadID":workloadID, "originator":"Client"}, 
                   {"_id":0, "originator":1, "conf":1, "clientSeqNo":1, "counters":1, "state":1, "jobMetaData":1})
               if defaultjob:
                    if 'counters' in defaultjob:
                         if 'MB_MILLIS_MAPS_TOTAL' in defaultjob['counters'] and 'MB_MILLIS_REDUCES_TOTAL' in defaultjob['counters']:
                              csvtable[workloadID]['Default_Memory'] = (defaultjob['counters']['MB_MILLIS_MAPS_TOTAL']['value'] + defaultjob['counters']['MB_MILLIS_REDUCES_TOTAL']['value']) / 1000000.00
                         if 'CPU_MILLISECONDS_MAP' in defaultjob['counters'] and 'CPU_MILLISECONDS_REDUCE' in defaultjob['counters']:
                              csvtable[workloadID]['Default_CPU'] = defaultjob['counters']['CPU_MILLISECONDS_MAP']['value'] + defaultjob['counters']['CPU_MILLISECONDS_REDUCE']['value']
                         if 'jobMetaData' in defaultjob:
                              if 'latency' in defaultjob['jobMetaData']:
                                   csvtable[workloadID]['Default_Latency'] = defaultjob['jobMetaData']['latency'] / 1000.00


# print header
firstItem = True
for key,value in csvtable['0'].iteritems():
     if firstItem:
          rowstr = str(value)
          firstItem = False
     else:
          rowstr += ", " + str(value)
print rowstr

#print rows
for workload in workloads:
     for costObjective in costObjectives:
          for dataSize in dataSizes:
               tagPrefix = workload + "_" + costObjective + "_" + dataSize + "_" + suffix
               found = False
               for workloadID, row in csvtable.iteritems():
                    tag = row['Tag']
                    if tag.find(tagPrefix) == 0:
                         found = True
                         break
               if not found:
                    continue
               firstItem = True
               for key in csvtable['0']:
                    if key in row:
                         value = str(row[key])
                    else:
                         value = "-1"
                    if firstItem:
                         rowstr = value
                         firstItem = False
                    else:
                         rowstr += ", " + value
               print rowstr
