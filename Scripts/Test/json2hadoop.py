#!/usr/bin/python

import json

s = ""
f = open("t.json")
j = json.load(f)
for key in j:
    for key2 in j[key]:
        if key2 == "value":
            s += "-D " + key + "=" + j[key][key2] + " "
print s
    
