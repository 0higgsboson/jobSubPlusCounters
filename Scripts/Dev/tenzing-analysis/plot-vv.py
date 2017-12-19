#!/usr/bin/python
import sys
import pymongo
from pymongo import MongoClient
import json
import numpy as np
import pandas as pd
from scipy import stats, integrate
import matplotlib.pyplot as plt
import seaborn as sns

sns.set(color_codes=True)


workloadID = sys.argv[1]
#print workloadID

client = MongoClient() 
db = client.sherpa
coll = db.tenzingHistory

cursor = coll.find({"workloadID":workloadID})

svlist = []
vellist = []
costlist = []

for job in cursor:
     for key in job.keys():
          if key == 'solutionVector':
               svlist.append(job[key])
          elif key == 'velocityVector':
               vellist.append(job[key])
          elif key == 'cost':
               costlist.append(job[key])

sv = np.array(svlist)
vv = np.array(vellist)
costs=np.array(costlist)

np.clip(costs, None, 200, out=costs)

#for i in range(0,len(sv[0])):
#     for j in range(0, len(sv[0,0])):
#          print sv[:,i,j]


def cost_plot():
     plt.title("Cost vs time")

     for i in range(0, len(costs[0])):
          plt.subplot(len(costs[0]), 1, i + 1)
          fig = plt.plot(costs[:,i])
          plt.ylabel('particle ' + str(i+1))
     plt.xlabel('time')
     plt.show()

def sol_vec_plot(s,t):
     plt.title(t)
     for i in range(0, len(s[0])):
          for j in range(0, len(s[0,0])):
               plt.subplot(len(s[0]), len(s[0,0]), i*len(s[0,0]) + j+1)
               if i == 0:
                    plt.title("Tunable " + str(j+1))
               fig = plt.plot(s[:,i,j])
               if j == 0:
                    plt.ylabel('sol_vec ' + str(i+1))
               if i == len(s[0]) - 1:
                    plt.xlabel('time')
     plt.show()

#cost_plot()

# sol_vec_plot(sv, "Solution Vectors vs time")

sol_vec_plot(vv, "Velocity Vectors vs time")

