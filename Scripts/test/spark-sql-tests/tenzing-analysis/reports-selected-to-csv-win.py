#!/usr/bin/python

import pymongo
from pymongo import MongoClient


skipHeaderRow = True

client = MongoClient() 
db = client.sherpa
coll = db.reports

cursor = coll.find()

table = [ [] ]
no_columns = 0
position = dict()


columns = list(['jobMetaData_finishTime' , 'jobMetaData_latency' , 'jobMetaData_executionTime' , 'jobMetaData_jobUrl' , 'jobMetaData_jobID' , 'jobMetaData_queue' , 'jobMetaData_sherpaTuned' , 'jobMetaData_tag' , 'jobMetaData_computeEngineType' , 'jobMetaData_costObjective' , 'jobMetaData_startTime' , 'jobMetaData_jobName' , 'jobMetaData_user' , 'state' , 'workloadID' , 'tenzingSeqNo' , 'counters_BYTES_READ_TOTAL_value' , 'counters_Memory_Bytes_Seconds_value' , 'counters_CPU_MILLISECONDS_REDUCE_value' , 'counters_CPU_MILLISECONDS_MAP_value' , 'counters_VCORES_MILLIS_MAPS_TOTAL_value' , 'counters_CPU_MILLISECONDS_value' , 'counters_PHYSICAL_MEMORY_BYTES_TOTAL_value' , 'counters_PHYSICAL_MEMORY_BYTES_MAP_value' , 'counters_Execution_Time_value' , 'counters_MB_MILLIS_MAPS_TOTAL_value' , 'counters_BYTES_WRITTEN_TOTAL_value' , 'counters_FILE_BYTES_READ_TOTAL_value' , 'counters_HDFS_BYTES_WRITTEN_TOTAL_value' , 'counters_VIRTUAL_MEMORY_BYTES_REDUCE_value' , 'counters_Latency_value' , 'counters_VIRTUAL_MEMORY_BYTES_TOTAL_value' , 'counters_FILE_BYTES_WRITTEN_TOTAL_value' , 'counters_PHYSICAL_MEMORY_BYTES_REDUCE_value' , 'counters_HDFS_BYTES_READ_TOTAL_value' , 'counters_CPU_MILLISECONDS_TOTAL_value' , 'counters_MB_MILLIS_REDUCES_TOTAL_value' , 'counters_VCORES_MILLIS_REDUCES_TOTAL_value' , 'conf_mapreduce_reduce_merge_inmem_threshold' , 'conf_mapreduce_reduce_cpu_vcores' , 'conf_java_heap_size_map' , 'conf_mapreduce_reduce_shuffle_input_buffer_percent' , 'conf_mapreduce_job_reduces' , 'conf_mapreduce_job_reduce_slowstart_completedmaps' , 'conf_mapreduce_reduce_shuffle_parallelcopies' , 'conf_mapreduce_task_io_sort_mb' , 'conf_mapreduce_map_cpu_vcores' , 'conf_mapreduce_tasktracker_indexcache_mb' , 'conf_mapreduce_reduce_shuffle_merge_percent' , 'conf_mapreduce_map_sort_spill_percent' , 'conf_mapreduce_map_memory_mb' , 'conf_mapreduce_reduce_input_buffer_percent' , 'conf_mapreduce_input_fileinputformat_split_maxsize' , 'conf_java_heap_size_reduce' , 'conf_mapreduce_reduce_memory_mb' , 'bestConf_mapreduce_reduce_merge_inmem_threshold' , 'bestConf_mapreduce_reduce_cpu_vcores' , 'bestConf_java_heap_size_map' , 'bestConf_mapreduce_reduce_shuffle_input_buffer_percent' , 'bestConf_mapreduce_job_reduces' , 'bestConf_mapreduce_job_reduce_slowstart_completedmaps' , 'bestConf_mapreduce_reduce_shuffle_parallelcopies' , 'bestConf_mapreduce_task_io_sort_mb' , 'bestConf_mapreduce_map_cpu_vcores' , 'bestConf_mapreduce_tasktracker_indexcache_mb' , 'bestConf_mapreduce_reduce_shuffle_merge_percent' , 'bestConf_mapreduce_map_sort_spill_percent' , 'bestConf_mapreduce_map_memory_mb' , 'bestConf_mapreduce_reduce_input_buffer_percent' , 'bestConf_mapreduce_input_fileinputformat_split_maxsize' , 'bestConf_java_heap_size_reduce' , 'bestConf_mapreduce_reduce_memory_mb' , 'originalConf_mapreduce_reduce_merge_inmem_threshold' , 'originalConf_mapreduce_reduce_cpu_vcores' , 'originalConf_java_heap_size_map' , 'originalConf_mapreduce_reduce_shuffle_input_buffer_percent' , 'originalConf_mapreduce_job_reduces' , 'originalConf_mapreduce_job_reduce_slowstart_completedmaps' , 'originalConf_mapreduce_reduce_shuffle_parallelcopies' , 'originalConf_mapreduce_task_io_sort_mb' , 'originalConf_mapreduce_map_cpu_vcores' , 'originalConf_mapreduce_tasktracker_indexcache_mb' , 'originalConf_mapreduce_reduce_shuffle_merge_percent' , 'originalConf_mapreduce_map_sort_spill_percent' , 'originalConf_mapreduce_map_memory_mb' , 'originalConf_mapreduce_reduce_input_buffer_percent' , 'originalConf_mapreduce_input_fileinputformat_split_maxsize' , 'originalConf_java_heap_size_reduce' , 'originalConf_mapreduce_reduce_memory_mb'])
 
i=0
for col in columns:
    position[col] = i
    i += 1

no_columns = i



def addthis(headerkey):
    global table
    global position
    global no_columns
#    if headerkey in position:
#        return
#    else:
#        print headerkey
    table[0].append(headerkey)
#        position[headerkey] = no_columns
#        no_columns += 1


for job in cursor:
    for key in job:
        if isinstance(job[key],dict):
            for key2 in job[key]:
                if isinstance(job[key][key2],dict):
                    for key3 in job[key][key2]:
#                        print key3, type(job[key][key2][key3]) 
                        addthis(key + '_' + key2 + '_' + key3)
                else:
                    addthis(key + '_' + key2)
        else:
            addthis(key)



cursor = coll.find()

#print no_columns

i = 0

for job in cursor:
    i += 1
    table.append( list([""] * (no_columns + 1)) )
    for key in job:
        if isinstance(job[key],dict):
            for key2 in job[key]:
                if isinstance(job[key][key2],dict):
                    for key3 in job[key][key2]:
                        if isinstance(job[key][key2][key3],dict):
                            print "Dict: ", job[key][key2][key3]
                        if key + '_' + key2 + '_' + key3 in columns:
                            table[i][position[key + '_' + key2 + '_' + key3]] = job[key][key2][key3]
#                            print "Setting row[", position[key + '_' + key2 + '_' + key3], "] to ", job[key][key2][key3]
                else:
                    if key + '_' + key2 in columns:
                        table[i][position[key + '_' + key2]] = job[key][key2]
#                        print "Setting row[", position[key + '_' + key2], "] to ", job[key][key2]
        else:
            if key in columns:
                table[i][position[key]] = job[key]
#                print "Setting row[", position[key], "] to ", job[key]


#s=""
#for col in columns:
#    s += col + "\t"
#print s + "\r"

firstRow=True
n=0
for row in table:
    if firstRow:
        firstRow = False
        continue
#    s = str(n) + "\t"
    s = ""
    firstElement = True
    pos = 0
    for element in row:
        pos += 1
#        if pos == 6:
#            continue
        e = str(element)
        if e == "Spark":
            firstElement=True
            break
        if e == "":
            e = "0"
#        e = '"' + e + '"'
        if firstElement:
            if "1970" in e:
                break
            firstElement = False
        else:
            s += "\t"
        s += e
    if not firstElement:
        print s + "\r"
        n += 1

