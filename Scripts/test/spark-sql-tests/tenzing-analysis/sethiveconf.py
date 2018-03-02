#!/usr/bin/python

import csv

with open('hiveboolconf.csv', 'rb') as csvfile:
    hiveconfreader = csv.reader(csvfile, delimiter=',', quotechar='"')
    firstrow = True
    s = ''
    for row in hiveconfreader:
        if firstrow:
#            print "Name, Type, Default,  Min, Max, Step Size"
            firstrow = False
            continue
        name = row[1]
        value = row[6]
        s += ' -hiveconf ' + name + '=' + value.lower()

print s





