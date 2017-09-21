#!/usr/bin/python

import sys
import pymongo
from pymongo import MongoClient
from datetime import datetime
import pytz
from pytz import utc, timezone

costObj = 'Memory'

if len(sys.argv) > 1:
    costObj = sys.argv[1]

def cost(job):
    cost = 0
    if 'counters' in job:
        if costObj == 'CPU':
            if 'CPU_MILLISECONDS_MAP' in job['counters']:
                cost = job['counters']['CPU_MILLISECONDS_MAP']['value']
            if 'CPU_MILLISECONDS_REDUCE' in job['counters']:
                cost += job['counters']['CPU_MILLISECONDS_REDUCE']['value']
            return cost / 60000.0
        if costObj == 'Memory':  
            if 'MB_MILLIS_MAPS_TOTAL' in job['counters']:
                cost = job['counters']['MB_MILLIS_MAPS_TOTAL']['value']
            if 'MB_MILLIS_REDUCES_TOTAL' in job['counters']:
                cost += job['counters']['MB_MILLIS_REDUCES_TOTAL']['value']
            return cost / 60000000.0
        if costObj == 'Latency':
                if 'Latency' in job['counters']:
                    return job['counters']['Latency']['value']
    return 0.0   




client = MongoClient() 
db = client.sherpa
coll = db.reports

cursor = coll.find()

timestamps = dict()
alltimestamps = []
nonTuned = dict()
tuned = dict()
allTuned = dict()
allNonTuned = dict()
cTuned = dict()
cNonTuned = dict()
cAllTuned = dict()
cAllNonTuned = dict()

for job in cursor:
    try:
        if job['state'] == "FAILURE" or cost(job) == 0:
            continue
        dt = datetime.strptime(job['jobMetaData']['startTime'], '%Y-%m-%d %H:%M:%S')
        timestamp = (dt - datetime(1970, 1, 1)).total_seconds()
        if job['jobMetaData']['sherpaTuned'] == 'Yes':
            if job['jobMetaData']['costObjective'] == costObj:
                allTuned[timestamp] = cost(job)
                alltimestamps.append(timestamp)
        else:
            allNonTuned[timestamp]  = cost(job)
            alltimestamps.append(timestamp)
    except:
        pass


tunedLatest = 0
nonTunedLatest = 0
prevTuned = 0
prevNonTuned = 0
for ts in sorted(alltimestamps):
    if ts in allTuned:
        tunedLatest = allTuned[ts]
        cAllTuned[ts] = allTuned[ts] + prevTuned
        prevTuned = cAllTuned[ts]
        cAllNonTuned[ts] = nonTunedLatest + prevNonTuned
        prevNonTuned = cAllNonTuned[ts]
    else:
        nonTunedLatest = allNonTuned[ts]
        cAllNonTuned[ts] = allNonTuned[ts] + prevNonTuned
        prevNonTuned = cAllNonTuned[ts]
        cAllTuned[ts] = tunedLatest + prevTuned
        prevTuned = cAllTuned[ts]
        
for ts in sorted(alltimestamps):
    s =  datetime.fromtimestamp(int(ts)).strftime('%Y-%m-%d %H:%M:%S') + "," + str(cAllTuned[ts]) + "," + str(cAllNonTuned[ts])
#    s =  "ALL," + str(int(ts)) + "," + str(cAllTuned[ts]) + "," + str(cAllNonTuned[ts])
    print s,"\r"
