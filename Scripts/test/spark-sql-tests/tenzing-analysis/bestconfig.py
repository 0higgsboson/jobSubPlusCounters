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
  if "bestConfig" in tz:
   if "clientSeqNo" in tz['bestConfig']:
     print "Client Seq No = ", tz['bestConfig']['clientSeqNo']
   bestConfig = tz['bestConfig']['tunedParams']
   s = ""
   if format == "csv":
      s += '"name", "value"\n'
   for confName, confValue in bestConfig.iteritems():
      val = confValue['value']
      confName = confName.replace('_','.')
      if format == "-D":
         if confName == "spark.executor.memory":
            s += " -D " + confName + "=" + val + "M"
         else:
            s += " -D " + confName + "=" + val
      elif format == "csv":
         if confName == "spark.executor.memory":
            s += " -D " + confName + "=" + val + "M"
         else:
            s += '"' + confName + '",' + val + "\n"
      else:
         if confName == "spark.executor.memory":
            s += " -D " + confName + "=" + val + "M"
         else:
            s += confName + " = " + val + "\n"
   if format == "csv":
      s += '"cost",' + str(tz['bestConfig']['cost']) + "\n"
   elif format != "-D":
      s += "----------------------------\n"
      s+= "cost = " + str(tz['bestConfig']['cost'])
   print s
