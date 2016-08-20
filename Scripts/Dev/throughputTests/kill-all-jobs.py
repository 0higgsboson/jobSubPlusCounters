#!/usr/bin/python

import subprocess
from operator import itemgetter

processes = subprocess.check_output(["hadoop job -list"],shell=True);

jobs = []
for line in processes.splitlines():
    if "job_" in line:
        jobs.append(list(line.split()))
sortedjobs = sorted(jobs,key=itemgetter(1))

for job in sortedjobs:
    print
    print "Killing job ", job[0]
    subprocess.call(["hadoop job -kill " + job[0]], shell=True);
 



