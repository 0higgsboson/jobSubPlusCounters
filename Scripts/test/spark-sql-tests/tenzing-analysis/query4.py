#!/usr/bin/python
import pymongo
from pymongo import MongoClient
client = MongoClient() 
db = client.sherpa
coll = db.reports
#cursor = coll.find({"workloadID":"cab379d7a10ec1bcb670c0bf63f743fa25b87ee1"}, 
cursor = coll.find({"workloadID":"24c9780ca5ef50a5a4c052d2e4f30558d6934681"}, 
                   {"_id":0, "conf":1, "clientSeqNo":1, "counters.VCORES_MILLIS_MAPS_TOTAL":1, "counters.VCORES_MILLIS_REDUCES_TOTAL":1, "state":1})



for job in cursor:
     print job['state']
     print job['counters']['VCORES_MILLIS_MAPS_TOTAL']['value'] + job['counters']['VCORES_MILLIS_REDUCES_TOTAL']['value']
     print job['conf']
#     print job['counters']['VCORES_MILLIS_MAPS_TOTAL']
