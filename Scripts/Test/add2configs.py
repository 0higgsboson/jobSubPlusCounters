#!/usr/bin/python

import json
import copy

f = open("/opt/sherpa/ClientAgent/configs.json")
configs = json.load(f)
f.close()

clientSeqNo = 0
for config in configs['cfgList']:
    if config['clientSeqNo'] > clientSeqNo:
        clientSeqNo = config['clientSeqNo']
    if config['originator'] == 'Tenzing':
        config['state'] = 'Successful'
clientSeqNo+=1

s = ""
f = open("manualconfigs.json")
newconfiglist = json.load(f)
f.close()

for c in newconfiglist['configs']:
    newconf = copy.deepcopy(config)
    newconf['clientSeqNo'] = clientSeqNo
    newconf['tenzingSeqNo'] = 0
    clientSeqNo += 1
    newconf['originator'] = 'client'
    newconf['state'] = 'Pending'
    clist = dict()
    for cfg in c:
         clist[cfg] = c[cfg]['value']
    newconf['conf'] = clist
    if 'counters' in newconf:
         del newconf['counters']
    configs['cfgList'].append(newconf)

f = open("./configs.json","w")
json.dump(configs,f)
f.close()






