#!/usr/bin/python
import sys
import pymongo
from pymongo import MongoClient

format = "screen" # Valid options: "screen", "-D", "csv" 
workloadID = sys.argv[1]
# print workloadID
if len(sys.argv) >= 3:
   format = sys.argv[2]

client = MongoClient() 
db = client.sherpa
tzcoll = db.tenzings
tzcursor = tzcoll.find({"workloadID":workloadID})
                       
for tz in tzcursor:
#   print tz['workloadID']
#   print tz['costObjective']
   bestConfig = tz['bestConfig']['tunedParams']
   s = ""
   if format == "csv":
       s += '"name", "value"\n'
   for confName, confValue in bestConfig.iteritems():
       if format == "-D":
           s += " -D " + confName + "=" + confValue['value']
       elif format == "csv":
           s += '"' + confName + '",' + confValue['value'] + "\n"
       else:
           s += confName + " = " + confValue['value'] + "\n"
   if format == "csv":
      s += '"cost",' + str(tz['bestConfig']['cost']) + "\n"
   elif format != "-D":
      s += "----------------------------\n"
      s+= "cost = " + str(tz['bestConfig']['cost'])
   print s
   
