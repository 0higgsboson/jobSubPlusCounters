#!/usr/bin/python

import fileinput

s = set()

for line in fileinput.input():
    if line in s:
        continue
    else:
        s.add(line)
        print str.strip(line)
