#!/usr/bin/python

# allows imports from parent/sibling
import sys, os
sys.path.insert(0, os.path.abspath('..'))

import subprocess
import shlex
from core import utils


utils.print_test_header("Mongo Data Delete")


contents= utils.get_json_file_contents("../data/data_1.json")
client = utils.get_mongo_client()
db = client.sherpa


# Test Case 1
db.reports.delete_many({})
db.reports.insert_many(contents)
subprocess.call(shlex.split('./mongo_data_remove.sh workloadID tc_1'))
count = db.reports.find({"workloadID": "tc_1"}).count()
assert count == 0, "Delete by workloadID failed ..."
count = db.reports.count()
assert count == 4, "Delete by workloadID deleted other workload's data ..."


# Test Case 2
db.reports.delete_many({})
db.reports.insert_many(contents)
subprocess.call(shlex.split('./mongo_data_remove.sh date "2016-07-01 00:00:00" "2016-07-03 23:59:59"'))
count = db.reports.find({"workloadID": "tc_1"}).count()
assert count == 2, "Delete by date failed ..."
count = db.reports.count()
assert count == 6, "Delete by date deleted other workload's data ..."


