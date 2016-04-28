#!/usr/bin/python
#
# This script purges completed jobs' configs from the /opt/sherpa/ClientAgent/configs.json file
# 
# Procedure:
# Log in to the client agent host
# kill Client Agent
# run this script
# copy the ./retainedConfigs.json file to /opt/sherpa/ClientAgent/configs.json
# start Client Agent
#
####################################################################

import json

f = open("/opt/sherpa/ClientAgent/configs.json")
configs = json.load(f)
f.close()

retainedConfigs = [];
purgedConfigs = [];

for config in configs['cfgList']:
    if config['state'] in ['PENDING', 'RUNNING']:
        retainedConfigs.append(config)
    else:
        purgedConfigs.append(config)

f = open("./retainedConfigs.json","w")
rc = {}
rc["cfgList"] = retainedConfigs
json.dump(rc,f)
f.close()

f = open("./purgedConfigs.json","w")
pc = {}
pc["cfgList"] = purgedConfigs
json.dump(pc,f)
f.close()
