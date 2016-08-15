#!/usr/bin/python

import json
import copy
from decimal import *

clientSeqNo = 0

def generateAllConfigs(c, existingconfig, clist):

    global clientSeqNo
    global configs
    global numConfigsAdded

#    print "---- generateAllConfigs ----"
#    print "c:"
#    print c
#    print "clist:"
#    print clist
#    print "configs:"
#    print configs
    cfgname = c.iterkeys().next()
    cfgval = c[cfgname]
    if 'type' in cfgval and cfgval['type'] == 'BOOLEAN':
        if cfgval['minVal'] == 'false':
            cfgval['minVal'] = 0
        else:
            cfgval['minVal'] = 1
        if cfgval['maxVal'] == 'false':
            cfgval['maxVal'] = 0
        else:
            cfgval['maxVal'] = 1

    value = Decimal(cfgval['minVal'])
 #   print "cfgval:"
 #   print cfgval
 #   print "[ ", cfgval['minVal'], " - ", cfgval['maxVal'], " ]"
    while value <= Decimal(cfgval['maxVal']):
        nextc = copy.deepcopy(c)
        nextc.pop(cfgname)
        nextclist = copy.deepcopy(clist)
        if cfgval['type'] == 'BOOLEAN':
            if value == 1:
                nextclist[cfgname] = 'true'
            else:
                nextclist[cfgname] = 'false'
        else:
            nextclist[cfgname] = str(value)

#        print "clist:"
#        print nextclist
#        print "nextc:"
#        print nextc
#        print bool(nextc)

        if bool(nextc):
            generateAllConfigs(nextc, existingconfig, nextclist)
        else:
            newconf = copy.deepcopy(existingconfig)
            newconf['clientSeqNo'] = clientSeqNo
            newconf['tenzingSeqNo'] = 0
            clientSeqNo += 1
            newconf['originator'] = 'client'
            newconf['state'] = 'Pending'
            newconf['conf'] = nextclist
            if 'counters' in newconf:
                del newconf['counters']
            configs['cfgList'].append(newconf)
#            print
#            print "Added Config:"
#            print newconf
            numConfigsAdded += 1
        value += Decimal(cfgval['stepSize'])    

f = open("/opt/sherpa/ClientAgent/configs.json")
configs = json.load(f)
f.close()

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
    numConfigsAdded = 0
    generateAllConfigs(c,config, dict())
    print "Generated ", numConfigsAdded, " configs"

f = open("./configs.json","w")
json.dump(configs,f)
f.close()



