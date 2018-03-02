#!/usr/bin/python
import sys
import pymongo
from pymongo import MongoClient
import json

workloadID = sys.argv[1]
#print workloadID

client = MongoClient() 
db = client.sherpa
coll = db.tenzingHistory

cursor = coll.find({"workloadID":workloadID})


firstRow = True
header = ""
for job in cursor:
     s = ""
     for key in job.keys():
          if firstRow:
               if isinstance(job[key], list):
                    if isinstance(job[key][0], list):
                         for i in range(0,len(job[key])):
                              for j in range(0,len(job[key][0])):
                                   header += key + "_" + str(i) + "_" + str(j) + ","
                    else:
                         for i in range(0,len(job[key])):
                              header += key + "_" + str(i) + ","
               else:
                    header += key + ","
          if isinstance(job[key], list):
               if isinstance(job[key][0], list):
                    for i in range(0,len(job[key])):
                         for j in range(0,len(job[key][0])):
                              s += str(job[key][i][j]) + ","
               else:
                    for i in range(0,len(job[key])):
                         s += str(job[key][i]) + ","
          else:
               s += str(job[key]) + ","
     if firstRow:
          print header
          firstRow = False
     print s
