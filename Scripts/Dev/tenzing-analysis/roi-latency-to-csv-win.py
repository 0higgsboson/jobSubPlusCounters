#!/usr/bin/python

import pymongo
from pymongo import MongoClient
from datetime import datetime
import pytz
from pytz import utc, timezone

def real_cost(job):
    costObj = 'Memory'
    if 'jobMetaData' in job:
        costObj = job['jobMetaData']['costObjective']
        if costObj == 'Latency' and 'latency' in job['jobMetaData']:
            return job['jobMetaData']['latency'] / 1000
    if 'counters' in job:
        if costObj == 'CPU':
            cost = 0
            if 'CPU_MILLISECONDS_MAP' in job['counters']:
                cost = job['counters']['CPU_MILLISECONDS_MAP']['value']
            if 'CPU_MILLISECONDS_REDUCE' in job['counters']:
                cost += job['counters']['CPU_MILLISECONDS_REDUCE']['value']
                return cost
            if costObj == 'Memory':  
                if 'MB_MILLIS_MAPS_TOTAL' in job['counters'] and 'MB_MILLIS_REDUCES_TOTAL' in job['counters']:
                    return (job['counters']['MB_MILLIS_MAPS_TOTAL']['value'] + job['counters']['MB_MILLIS_REDUCES_TOTAL']['value']) / 60000000.0
            if costObj == 'Latency':
                if 'Latency' in job['counters']:
                    return job['counters']['Latency']
    return 0   

def cost(job):
    if 'counters' in job:
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
    workloadID = job['workloadID']
    if workloadID not in timestamps:
        timestamps[workloadID] = []
        nonTuned[workloadID] = dict()
        tuned[workloadID] = dict()
    dt = datetime.strptime(job['jobMetaData']['startTime'], '%Y-%m-%d %H:%M:%S')
    timestamp = (dt - datetime(1970, 1, 1)).total_seconds()
    timestamps[workloadID].append(timestamp)
    alltimestamps.append(timestamp)
    if job['jobMetaData']['sherpaTuned'] == 'Yes':
        allTuned[timestamp] = tuned[workloadID][timestamp] = cost(job)
    else:
        allNonTuned[timestamp] = nonTuned[workloadID][timestamp] = cost(job)

for w in timestamps:
    noTuned = 0
    noNonTuned = 0
    tunedAvg = 0
    nonTunedAvg = 0
    prevTuned = 0
    prevNonTuned = 0
    cTuned[w] = dict()
    cNonTuned[w] = dict()
    for ts in sorted(timestamps[w]):
        if ts in tuned[w]:
            if noTuned == 0:
                tunedAvg = tuned[w][ts]
            else:
                tunedAvg = (tunedAvg * noTuned + tuned[w][ts]) / (noTuned + 1)
            noTuned += 1
            cTuned[w][ts] = tuned[w][ts] + prevTuned
            prevTuned = cTuned[w][ts]
            cNonTuned[w][ts] = nonTunedAvg + prevNonTuned
            prevNonTuned = cNonTuned[w][ts]
        else:
            if noNonTuned == 0:
                nonTunedAvg = nonTuned[w][ts]
            else:
                nonTunedAvg = (nonTunedAvg * noNonTuned + nonTuned[w][ts]) / (noNonTuned + 1)
            noNonTuned += 1
            cNonTuned[w][ts] = nonTuned[w][ts] + prevNonTuned
            prevNonTuned = cNonTuned[w][ts]
            cTuned[w][ts] = tunedAvg + prevTuned
            prevTuned = cTuned[w][ts]
            

for w in timestamps:
    for ts in sorted(timestamps[w]):
        s =  str(w) + "," + datetime.fromtimestamp(int(ts)).strftime('%Y-%m-%d %H:%M:%S') + "," + str(cTuned[w][ts]) + "," + str(cNonTuned[w][ts])
#        s =  str(w) + "," + str(int(ts)) + "," + str(cTuned[w][ts]) + "," + str(cNonTuned[w][ts])
        print s,"\r"

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
    s =  "ALL," + datetime.fromtimestamp(int(ts)).strftime('%Y-%m-%d %H:%M:%S') + "," + str(cAllTuned[ts]) + "," + str(cAllNonTuned[ts])
#    s =  "ALL," + str(int(ts)) + "," + str(cAllTuned[ts]) + "," + str(cAllNonTuned[ts])
    print s,"\r"
