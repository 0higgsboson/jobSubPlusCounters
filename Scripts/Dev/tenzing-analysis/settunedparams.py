#!/usr/bin/python

import json
import csv
import collections
from collections import OrderedDict

with open('tunedparams.json') as configs_file:    
    configs = json.load(configs_file, object_pairs_hook=OrderedDict)

for config in configs:
    print configs[config]

with open('hiveconfigs.csv', 'rb') as csvfile:
    hiveconfreader = csv.reader(csvfile, delimiter=',', quotechar='"')
    firstrow = True
    for row in hiveconfreader:
        if firstrow:
            print "Name, Type, Default,  Min, Max, Step Size"
            firstrow = False
            continue
        name = row[1]
        default = row[3]
        _type = row[2]
        _min = row[4]
        _max = row[5]
        step = row[6]
        if _type == 'Int':
            _type = 'INT'
        elif _type == 'Float':
            _type = 'DOUBLE'
        print name, ",", _type, ",", default, ",", _min, ",", _max, ",", step
        config = collections.OrderedDict()
        config['name'] = name
        config['value'] = default
        config['type'] = _type
        config['minVal'] = _min
        config['maxVal'] = _max
        config['stepSize'] = step
        configs[name] = config

print configs

with open('hivetunedparams.json', 'w') as outfile:
    json.dump(configs, outfile, indent=4)




