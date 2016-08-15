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
import os.path

utils.print_test_header("Job Log File")
log_filename = "/opt/sherpa.log"
print "Preparing job's input/output paths ..."
jar = utils.get_hadoop_examples_jar()
subprocess.call(shlex.split('hdfs dfs -rm -r /tests/input/'))
subprocess.call(shlex.split('hdfs dfs -rm -r /tests/output/'))
subprocess.call(shlex.split('hdfs dfs -mkdir -p /tests/input'))
subprocess.call(shlex.split('hdfs dfs -copyFromLocal original_configs_test.py /tests/input/'))

print "Deleting existing log file: " + log_filename
utils.delete_file(log_filename)

print("Running MR Job ...")
utils.delete_file("log.txt")
command = 'yarn jar ' + jar + ' wordcount -D PSManaged=true -D SherpaCostObj=Latency /tests/input/ /tests/output/'
log_file = open("log.txt", "w")
subprocess.call(shlex.split(command), shell=False, stdout=log_file, stderr=subprocess.STDOUT)
log_file.close()


file_size = os.stat(log_filename).st_size
print("File Size: " + str(file_size))
if os.path.isfile(log_filename) and os.stat(log_filename).st_size != 0:
    utils.print_test_status("Success")
else:
    utils.print_test_status("Failed")



