#!/usr/bin/python

import json
import collections
from collections import OrderedDict

configs = OrderedDict()

minval=0
maxval=100
defaultval=50
valtype='DOUBLE'
stepSize=1
namePrefix='p'

n = 10

for i in range(0,n):
    name = namePrefix + "{0:0>3}".format(i+1)
    config = collections.OrderedDict()
    config['name'] = name
    config['value'] = defaultval
    config['type'] = valtype
    config['minVal'] = minval
    config['maxVal'] = maxval
    config['stepSize'] = stepSize
    configs[name] = config

print json.dumps(configs, indent=4)


