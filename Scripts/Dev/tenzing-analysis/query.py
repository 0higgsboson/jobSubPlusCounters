#!/usr/bin/python
import pymongo
from pymongo import MongoClient
client = MongoClient() 
db = client.sherpa
coll = db.reports
cursor = coll.find({"workloadID": "33841de641ba72995f981db6b8a816c1a80d7c1f",
                  #   "clientSeqNo": 2
                 },
                    {"_id":0, "workloadID":1, "clientSeqNo": 1, "tenzingSeqNo":1,
                     "configs":1,
                     "counters.VCORES_MILLIS_MAPS_TOTAL":1,
                     "counters.VCORES_MILLIS_REDUCES_TOTAL":1
                    })

for job in cursor:
     print job
