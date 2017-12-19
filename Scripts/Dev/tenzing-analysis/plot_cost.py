#!/usr/bin/python

import numpy as np
import pandas as pd
from scipy import stats, integrate
import matplotlib.pyplot as plt
import sys
import pymongo
from pymongo import MongoClient
import json
import seaborn as sns

workloadID = sys.argv[1]

sns.set(color_codes=True)

client = MongoClient() 
db = client.sherpa
coll = db.reports


cursor = coll.find({"workloadID":workloadID}, 
                   {"_id":0, "originator":1, "conf":1, "clientSeqNo":1, "counters":1, "state":1, "jobMetaData":1,
                    "memoryMetric":1, "cpuMetric":1, "latencyMetric":1, "throughputJobLevelMetric":1, "throughputTaskLevelMetric":1, "throughputTaskLevelMetric2":1})

success = []
failure = []

i = 0
for job in cursor:
     i += 1
     if 'conf' in job:
          config = job['conf']
     if 'counters' in job:
          cpu = None
          mem = None
          latency = None
          if 'CPU_MILLISECONDS_MAP' in job['counters'] and 'CPU_MILLISECONDS_REDUCE' in job['counters']:
               cpu = job['counters']['CPU_MILLISECONDS_MAP']['value'] + job['counters']['CPU_MILLISECONDS_REDUCE']['value']
          if job['state'] == 'SUCCESS':
              success.append([i, cpu])
          else:
              failure.append([i, cpu])


s = np.array(success)
f = np.array(failure)

#df1 = pd.DataFrame(s, columns=['x1', 'y1'])
#df2 = pd.DataFrame(f, columns=['x2', 'y2'])

#graph = sns.jointplot(x=df2.x2, y=df2.y2, color='r')
#graph.x = df1.x1
#graph.y = df1.y1
#graph.plot_joint(plt.scatter, marker='x', c='b', s=50)

# plt.plot(s[:,0],s[:,1],'go',f[:,0],f[:,1],'ro')

if len(s) > 0:
     fig = plt.plot(s[:,0],s[:,1],'go')
if len(f) > 0:
     fig = plt.plot(f[:,0],f[:,1],'ro')


plt.show()
