#!/usr/bin/python
import pymongo
from pymongo import MongoClient
import collections

client = MongoClient() 
db = client.sherpa
coll = db.reports
cursor = coll.find({},
                    {"_id":0, "workloadID":1, "jobMetaData.tag":1
                    })

s = collections.OrderedDict()
no = dict()
tag = dict()
for job in cursor:
     if job['workloadID'] in s:
          no[job['workloadID']] += 1
          continue
     else:
          s[job['workloadID']] = 1
          no[job['workloadID']] = 1
          tag[job['workloadID']] = job['jobMetaData']['tag']

for workloadID in s:
     print workloadID, "....", tag[workloadID], "... (", no[workloadID], ")"
#          print job['workloadID'], "....", job['jobMetaData']['tag']



