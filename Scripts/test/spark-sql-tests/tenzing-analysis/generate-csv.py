#!/usr/bin/python
import sys
import pymongo
from pymongo import MongoClient

import csv

def write_dict_data_to_csv_file(csv_file_path, dict_data):
    csv_file = open(csv_file_path, 'wb')
    writer = csv.writer(csv_file, dialect='excel')
    
    headers = dict_data[0].keys()
    writer.writerow(headers)

    for dat in dict_data:
        line = []
        for field in headers:
             if field in dat:
                  line.append(dat[field])
             else:
                  line.append("")
        writer.writerow(line)
        
    csv_file.close()


workloadID = sys.argv[1]
print workloadID

client = MongoClient() 
db = client.sherpa
coll = db.reports

cursor = coll.find({"workloadID":workloadID}, 
                   {"_id":0, "conf":1, "clientSeqNo":1, "counters":1, "state":1, "jobMetaData":1, "originator":1})

dict_data = []
i=0

for job in cursor:
     dict_data.append(job['conf'])
     dict_data[i]['state'] = job['state']
     dict_data[i]['originator'] = job['originator']
     dict_data[i]['VCores'] = job['counters']['VCORES_MILLIS_MAPS_TOTAL']['value'] + job['counters']['VCORES_MILLIS_REDUCES_TOTAL']['value']
     dict_data[i]['CPU'] = job['counters']['CPU_MILLISECONDS_MAP']['value'] + job['counters']['CPU_MILLISECONDS_REDUCE']['value']
     dict_data[i]['Memory'] = job['counters']['MB_MILLIS_MAPS_TOTAL']['value'] + job['counters']['MB_MILLIS_REDUCES_TOTAL']['value']
     dict_data[i]['Latency'] = job['jobMetaData']['latency']
     i+=1

write_dict_data_to_csv_file('mycsv.csv', dict_data)
