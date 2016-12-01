#!/usr/bin/python
import pymongo
from pymongo import MongoClient
import collections

def computeGain(r):
     try:
          if r['CostObjective'] == "Latency":
               return r['Default_Latency'] / r['Latency']
          elif r['CostObjective'] == "Memory":
               return r['Default_Memory'] / r['Memory']
          elif r['CostObjective'] == "CPU":
               return (1.0 * r['Default_CPU']) / r['CPU']
          elif r['CostObjective'] == "MemCPU":
               return min(r['Default_CPU'] / r['CPU'], r['Default_Memory'] / r['Memory'])
     except KeyError:
          print "Key Error: "
          print r
          return 0



#workloads = ["terasort", "sort", "wordcount", "aggregation", "join"]
#workloads = ["terasort", "sort", "wordcount"]
#workloads = ["aggregation", "join"]
workloads = ["aggregation", "join", "scan"]
dataSizes = ["1GB"]
costObjectives = ["CPU", "Memory", "Latency"]
suffix = "newtag-snowflake-11-30-2016-"
low = 1
high = 2

client = MongoClient() 
db = client.sherpa
coll = db.reports
tzcoll = db.tenzings
cursor = coll.find({},
                    {"_id":0, "workloadID":1, "jobMetaData.tag":1
                    })

s = set()
d = dict()
csvtable = collections.OrderedDict()
firstLine = True
for job in cursor:
     found = False
     for w in workloads:
          if job['jobMetaData']['tag'].find(w) != -1:
               found = True
               break
     if not found:
          continue
     elif job['workloadID'] in s:
          continue
     elif job['jobMetaData']['tag'].find(suffix) == -1:
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
                    csvtable['0']['Memory'] = "Memory"
                    csvtable['0']['Default_Memory'] = "Default_Memory"
                    csvtable['0']['CPU'] = "CPU"
                    csvtable['0']['Default_CPU'] = "Default_CPU"
                    csvtable['0']['Latency'] = "Latency"
                    csvtable['0']['Default_Latency'] = "Default_Latency"
                    csvtable['0']['Gain'] = "Gain"
                    csvtable['0']['CostObjective'] = "CostObjective"
                    firstLine = False
               csvtable[workloadID]['Cost'] = tz['bestConfig']['cost']
               csvtable[workloadID]['CostObjective'] = tz['costObjective']
               job = tz['bestConfig']
#               print job
               if 'counters' in job:
                    csvtable[workloadID]['CPU'] = 0
                    if 'CPU_MILLISECONDS_MAP' in job['counters']:
                         csvtable[workloadID]['CPU'] += job['counters']['CPU_MILLISECONDS_MAP']['value']
                    if 'CPU_MILLISECONDS_REDUCE' in job['counters']:
                         csvtable[workloadID]['CPU'] += job['counters']['CPU_MILLISECONDS_REDUCE']['value']
                    csvtable[workloadID]['Memory'] = 0
                    if 'MB_MILLIS_MAPS_TOTAL' in job['counters']:
                         csvtable[workloadID]['Memory'] += job['counters']['MB_MILLIS_MAPS_TOTAL']['value'] / 1000000.00
                    if 'MB_MILLIS_REDUCES_TOTAL' in job['counters']:
                         csvtable[workloadID]['Memory'] += job['counters']['MB_MILLIS_REDUCES_TOTAL']['value'] / 1000000.00
                    if 'jobMetaData' in job:
                         if 'latency' in job['jobMetaData']:
                              csvtable[workloadID]['Latency'] = job['jobMetaData']['latency'] / 1000.00
               defaultjob = coll.find_one({"workloadID":workloadID, "originator":"Client"}, 
                   {"_id":0, "originator":1, "conf":1, "clientSeqNo":1, "counters":1, "state":1, "jobMetaData":1})
               if defaultjob:
                    if 'counters' in defaultjob:
                         if 'MB_MILLIS_MAPS_TOTAL' in defaultjob['counters']:
                              csvtable[workloadID]['Default_Memory'] = defaultjob['counters']['MB_MILLIS_MAPS_TOTAL']['value'] / 1000000.00
                              if 'MB_MILLIS_REDUCES_TOTAL' in defaultjob['counters']:
                                   csvtable[workloadID]['Default_Memory'] += defaultjob['counters']['MB_MILLIS_REDUCES_TOTAL']['value'] / 1000000.00
                         else:
                              csvtable[workloadID]['Default_Memory'] = 0
                         if 'CPU_MILLISECONDS_MAP' in defaultjob['counters']:
                              csvtable[workloadID]['Default_CPU'] = defaultjob['counters']['CPU_MILLISECONDS_MAP']['value']
                              if 'CPU_MILLISECONDS_REDUCE' in defaultjob['counters']:
                                   csvtable[workloadID]['Default_CPU'] += defaultjob['counters']['CPU_MILLISECONDS_REDUCE']['value']
                         else:
                              csvtable[workloadID]['Default_CPU'] = 0
                         if 'jobMetaData' in defaultjob:
                              if 'latency' in defaultjob['jobMetaData']:
                                   csvtable[workloadID]['Default_Latency'] = defaultjob['jobMetaData']['latency'] / 1000.00
                              else:
                                   csvtable[workloadID]['Default_Latency'] = 0
                         csvtable[workloadID]['Gain'] = computeGain(csvtable[workloadID])
               if tag in d:
                    prevWID = d[tag]
                    #                    print "##### Consolidating workload ", workloadID, " and ", prevWID
                    div = 1.0
                    csvtable[prevWID]['Cost'] += csvtable[workloadID]['Cost'] / div
                    csvtable[prevWID]['Memory'] += csvtable[workloadID]['Memory'] / div
                    csvtable[prevWID]['Default_Memory'] += csvtable[workloadID]['Default_Memory'] / div
                    csvtable[prevWID]['CPU'] += csvtable[workloadID]['CPU'] / div
                    csvtable[prevWID]['Default_CPU'] += csvtable[workloadID]['Default_CPU'] / div
                    csvtable[prevWID]['Latency'] += csvtable[workloadID]['Latency'] / div
                    csvtable[prevWID]['Default_Latency'] += csvtable[workloadID]['Default_Latency'] / div
                    csvtable[prevWID]['Gain'] = computeGain(csvtable[prevWID])
                    csvtable[workloadID]['Tag'] = "DUP_" + csvtable[workloadID]['Tag']
               else:
                    d[tag] = workloadID
# print header
firstItem = True
for key,value in csvtable['0'].iteritems():
     if firstItem:
          rowstr = str(value)
          firstItem = False
     else:
          rowstr += ", " + str(value)
print rowstr
print "Range"
print "Min Values"
rowcount = 3
rangeRow = 2

#print rows
for workload in workloads:
     for costObjective in costObjectives:
          for dataSize in dataSizes:
               for iterno in range(low, high+1) :
                    if iterno == -1:
                         tagPrefix = workload + "_" + costObjective + "_" + dataSize + "_" + suffix
                    else:
                         tagPrefix = workload + "_" + costObjective + "_" + dataSize + "_" + suffix + str(iterno)
                    found = False
                    for workloadID, row in csvtable.iteritems():
                         tag = row['Tag']
#                         print tagPrefix, "   ....   ", tag
                         if tag.find(tagPrefix) == 0 or tag.find("DUP_" + tagPrefix) == 0:
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
                    if iterno == -1:
                         break
               if iterno != -1 and high != low:
                    min = rowcount + 1
                    max = rowcount + 1 + high - low
                    rowcount += high - low + 4
                    cols = len(row['Tag']) - 1
                    col = "C"
                    row = max + 1
                    rowstr = "Average, "
                    for i in range(0,cols):
                         rowstr += ",=AVERAGE("+col+str(min)+":"+col+str(max)+")"
                         if col == 'Z':
                              break
                         else:
                              col = chr(ord(col)+1)
                    print rowstr
                    rowstr = "Std Dev / Avg, "
                    col = "C"
                    for i in range(0,cols):
                         rowstr += ",=STDEV.P("+col+str(min)+":"+col+str(max)+") / "+col+str(row)
                         if col == 'Z':
                              break
                         else:
                              col = chr(ord(col)+1)
                    print rowstr
                    rowstr = "Std Dev / Range, "
                    row+=1
                    col = "C"
                    for i in range(0,cols):
                         rowstr += ",="+col+str(row)+" / " + col + str(rangeRow)
                         if col == 'Z':
                              break
                         else:
                              col = chr(ord(col)+1)
                    print rowstr
