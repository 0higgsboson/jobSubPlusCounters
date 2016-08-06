#!/usr/bin/python
import pymongo
from pymongo import MongoClient
client = MongoClient() 
db = client.sherpa
coll = db.reports
cursor = coll.find({},
                    {"_id":0})

for job in cursor:
    print job.keys()
    print job["jobMetaData"].keys()
    break

