#!/usr/bin/python
import sys
import pymongo
from pymongo import MongoClient
import json
import collections
from csvUtils import *

def set_cursor() :
     return coll.find({}, {"_id":0, "allConfigs":0})

if(len(sys.argv) != 4):
     print "Usage: r2csv.py tableName SQLfile CSVfile"
     sys.exit(1)



tableName = sys.argv[1]
sqlFile = sys.argv[2]
csvFile = sys.argv[3]

header = []

client = MongoClient() 
db = client.sherpa
coll = db.reports

cursor = set_cursor()

for tz in cursor:
     build_header(header, "", tz)

add_result_columns_to_header(header)


header.sort()

sf = open(sqlFile, "w")
generate_sql_file(sf, tableName, header, newline="\r\n")
sf.close()


f = open(csvFile, "w")

print_row_to_file(f, header, separator=", ", newline="\r\n")

pos = dict()

set_pos(pos, header)


cursor = set_cursor()

for tz in cursor:
     row = [""] * len(header)
     add_row(row, pos, "", tz)
     add_results_to_row(row,pos)
     print_row_to_file(f, row, separator=", ", newline="\r\n")

f.close()
