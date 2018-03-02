#!/usr/bin/python
import sys
import pymongo
from pymongo import MongoClient
import json
import collections
from csvUtils import *

def set_cursor() :
     return coll.find({}, {"ctCfgList":0, "_id":0})

if(len(sys.argv) != 4):
     print "Usage: t2csv.py tableName SQLfile CSVfile"
     sys.exit(1)



tableName = sys.argv[1]
sqlFile = sys.argv[2]
csvFile = sys.argv[3]

header = []

client = MongoClient() 
db = client.sherpa
coll = db.tenzings

cursor = set_cursor()

for tz in cursor:
     build_header(header, "", tz)

header.sort()

sf = open(sqlFile, "w")
generate_sql_file(sf, tableName, header, newline="\r\n")
sf.close()

# print_row(header)

pos = dict()

set_pos(pos, header)


cursor = set_cursor()

f = open(csvFile, "w")
for tz in cursor:
     row = [""] * len(header)
     add_row(row, pos, "", tz)
     print_row_to_file(f, row, separator=", ", newline="\r\n")

f.close()
