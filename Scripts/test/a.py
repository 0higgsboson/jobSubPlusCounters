#!/usr/bin/python
from pymongo import MongoClient
from core.configs import settings
import json
import copy


f = open("data/data_1.json")
record = json.load(f)
f.close()

client = MongoClient("mongodb://"+settings['mongo_host']+":"+settings['mongo_port'])
db = client.sherpa
db.reports.delete_many({})
db.reports.insert_many(record)

count = db.reports.count()
print(count)