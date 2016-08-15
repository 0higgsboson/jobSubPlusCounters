#!/usr/bin/python

# allows imports from parent/sibling
import sys, os
sys.path.insert(0, os.path.abspath('..'))

from core import utils
from core.configs import settings
import os
import paramiko
import subprocess
import shlex
from shutil import copyfile


def run_test():
    counter_names = {}

    with open("/opt/job_counters.txt", "r") as lines:
        for line in lines:
            counter_names[line.rstrip('\n')] = ""
    print "Number of Counters: " + str(len(counter_names))

    print "Preparing job's input/output paths ..."
    jar = utils.get_hadoop_examples_jar()
    subprocess.call(shlex.split('hdfs dfs -rm -r /tests/input/'))
    subprocess.call(shlex.split('hdfs dfs -rm -r /tests/output/'))
    subprocess.call(shlex.split('hdfs dfs -mkdir -p /tests/input'))
    subprocess.call(shlex.split('hdfs dfs -copyFromLocal original_configs_test.py /tests/input/'))

    print "Flushing db ..."
    client = utils.get_mongo_client()
    db = client.sherpa
    db.reports.delete_many({})

    print("Running MR Job ...")
    utils.delete_file("log.txt")
    command = 'yarn jar ' + jar + ' wordcount -D PSManaged=true -D SherpaCostObj=Latency /tests/input/ /tests/output/'
    log_file = open("log.txt", "w")
    subprocess.call(shlex.split(command), shell=False, stdout=log_file, stderr=subprocess.STDOUT)
    log_file.close()


    count = db.reports.count()
    if(count==0):
        print "Error: No record found in db ..."
        utils.print_test_status("Failed")


    record = db.reports.find_one({})
    counters = record['counters']
    # if( len(counters) != len(counter_names) ):
    #     print "Error: Different number of counters found in db: " + str(len(counters)) + " then what set in whitelist: " + str(len(counter_names))
    #     utils.print_test_status("Failed")
    #     return

    print("Checking counter names ...")
    print("Total Counters:" + str(len(counters)))
    isSucceeded = True
    for k in counters:
        if ( not k.endswith("_MAP") and not k.endswith("_REDUCE") and not k.endswith("_TOTAL") ):
            continue

        index = k.rfind("_")
        k = k[:index]
        if k not in counter_names:
           isSucceeded = False
           print "Error: Counter name " + k + " was not in whitelist ..."
           break

    if isSucceeded:
        utils.print_test_status("Success")
    else:
        utils.print_test_status("Failed")




utils.print_test_header("All Job Counters Whitelist")
utils.delete_file("/opt/job_counters.txt")
copyfile("job_counters_all.txt", "/opt/job_counters.txt")
run_test()

print ""

utils.print_test_header("Some Job Counters Whitelist")
utils.delete_file("/opt/job_counters.txt")
copyfile("job_counters_few.txt", "/opt/job_counters.txt")
run_test()
