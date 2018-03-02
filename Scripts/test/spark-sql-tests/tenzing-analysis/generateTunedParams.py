#!/usr/bin/python

import sys
import json
import collections
from collections import OrderedDict

configs = OrderedDict()


n = int(float(sys.argv[1]))
minval= int(float(sys.argv[2]))
maxval= int(float(sys.argv[3]))
defaultval= int(float(sys.argv[4]))

valtype='DOUBLE'
stepSize=1
namePrefix='p'


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


