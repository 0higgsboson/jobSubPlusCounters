#!/usr/bin/python
import pymongo
from pymongo import MongoClient
client = MongoClient() 
db = client.sherpa
coll = db.reports
cursor = coll.find({},
                    {"_id":0, "workloadID":1, "jobMetaData.tag":1
                    })

for job in cursor:
     print job['workloadID'], "....", job['jobMetaData']['tag']


