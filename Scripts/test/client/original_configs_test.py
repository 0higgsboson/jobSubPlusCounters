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
from time import sleep

utils.print_test_header("Original Configs Save & Circuit Breaker Status Tests")

jar = utils.get_hadoop_examples_jar()
subprocess.call(shlex.split('hdfs dfs -rm -r /tests/input/'))
subprocess.call(shlex.split('hdfs dfs -rm -r /tests/output/'))
subprocess.call(shlex.split('hdfs dfs -mkdir -p /tests/input'))
subprocess.call(shlex.split('hdfs dfs -copyFromLocal original_configs_test.py /tests/input/'))


#replace the configs with restricted one to make the job fail
tenzing_server = settings['tenzing_host']
utils.upload_file_on_server(tenzing_server, "restricted_tunedparams.json", settings['tenzing_path']+"tunedparams.json")
#utils.run_command_on_server(tenzing_server, "supervisorctl restart Tomcat")
#sleep(20)


client = utils.get_mongo_client()
db = client.sherpa
job_recovered = False
print("Running MR jobs till we get one recovered one ...")
while not job_recovered:

    print "Flushing db ..."
    db.reports.delete_many({})

    print "Removing any previous log file ..."
    utils.delete_file("log.txt")

    print "Running MR Job ..."
    command = 'yarn jar ' + jar + ' wordcount -D PSManaged=true -D SherpaCostObj=Latency /tests/input/ /tests/output/'
    log_file = open("log.txt", "w")
    subprocess.call(shlex.split(command), shell=False, stdout=log_file, stderr=subprocess.STDOUT)
    log_file.close()
    job_recovered = utils.is_recovered_job("log.txt")


print "Job Recovered ..."
# restore original configs

print "Restoring tunedparams ..."
utils.upload_file_on_server(tenzing_server, "tunedparams.json", settings['tenzing_path']+"tunedparams.json")
#utils.run_command_on_server(tenzing_server, "supervisorctl restart Tomcat")



count = db.reports.count()
if(count==0):
    utils.print_test_status("Both Tests Failed")
    sys.exit()

cursor = db.reports.find({})
for c in cursor:
    if (len(c['originalConf']) > 0):
        utils.print_test_status("Original Configs Save Test: Success")
    else:
        utils.print_test_status("Original Configs Save Test: Failed")

    if (c['tunedParamsTypes'] == "BEST" or c['tunedParamsTypes'] == "DEFAULT" ):
        utils.print_test_status("Circuit Breaker Status Test: Success")
    else:
        utils.print_test_status("Circuit Breaker Status Test: Failed")


