#!/usr/bin/python
from pymongo import MongoClient
from core.configs import settings
import json
import os
import paramiko


def get_mongo_client():
    client = MongoClient("mongodb://"+settings['mongo_host']+":"+settings['mongo_port'])
    print "Connecting to Mongo At: " + settings['mongo_host']+":"+settings['mongo_port']
    return client


def get_json_file_contents(file):
    f = open(file)
    contents = json.load(f)
    f.close()
    return contents


def upload_file_on_server(server, src_file, dst_file):
    print("Uploading File: [ src_file=" + src_file + ", dst_file= " + dst_file +", server=" + server + " ]")
    ssh = paramiko.SSHClient()
    #ssh.load_host_keys(os.path.expanduser(os.path.join("~", ".ssh", "known_hosts")))
    ssh.set_missing_host_key_policy( paramiko.AutoAddPolicy() )
    ssh.connect(server)
    sftp = ssh.open_sftp()
    sftp.put(src_file, dst_file)
    sftp.close()
    ssh.close()


def run_command_on_server(server, command):
    print("Running Remote Command: [ command=" + command  +", server=" + server + " ]")

    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy( paramiko.AutoAddPolicy() )
    client.connect(server)
    stdin, stdout, stderr = client.exec_command(command)
    error=str(stderr.readlines())
    print "stderr: ", error
    print "stdout: ", stdout.readlines()
    if(error!="[]" ):
        print "Error"
        return False
    else:
        print "Success"
        return True

def get_ssh_client(server):
    client = paramiko.SSHClient()
    client.load_system_host_keys()
    client.set_missing_host_key_policy( paramiko.AutoAddPolicy() )
    client.connect(server)
    return client

def get_hadoop_examples_jar():
    jar = settings['hadoop_install_dir'] + "hadoop-" + settings['hadoop_version']+ "/share/hadoop/mapreduce/hadoop-mapreduce-examples-"+settings['hadoop_version']+".jar"
    return jar


def check_str_in_file(file, str):
    if str in open(file).read():
        return True
    else:
        return False


def is_recovered_job(file):
    return check_str_in_file(file, "Job Status?: RECOVERED")


def delete_file(file):
    try:
        os.remove(file)
    except OSError:
        pass

def print_test_header(msg):
    print "---------------------------------------------------------------------------------------------------------------------------------------------------------------"
    print "Running Test: " + msg
    print "==============================================================================================================================================================="


def print_test_status(status):
    print "--------------------------------------------------------------------------------------"
    print "Test Status: " + status
    print "--------------------------------------------------------------------------------------"
    print ""
