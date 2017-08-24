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


columns = set(['jobMetaData_finishTime' , 'jobMetaData_latency' , 'jobMetaData_executionTime' , 'jobMetaData_jobUrl' , 'jobMetaData_jobID' , 'jobMetaData_queue' , 'jobMetaData_sherpaTuned' , 'jobMetaData_tag' , 'jobMetaData_computeEngineType' , 'jobMetaData_costObjective' , 'jobMetaData_startTime' , 'jobMetaData_jobName' , 'jobMetaData_user' , 'state' , 'workloadID' , 'tenzingSeqNo' , 'counters_BYTES_READ_TOTAL_value' , 'counters_Memory_Bytes_Seconds_value' , 'counters_CPU_MILLISECONDS_REDUCE_value' , 'counters_CPU_MILLISECONDS_MAP_value' , 'counters_VCORES_MILLIS_MAPS_TOTAL_value' , 'counters_CPU_MILLISECONDS_value' , 'counters_PHYSICAL_MEMORY_BYTES_TOTAL_value' , 'counters_PHYSICAL_MEMORY_BYTES_MAP_value' , 'counters_Execution_Time_value' , 'counters_MB_MILLIS_MAPS_TOTAL_value' , 'counters_BYTES_WRITTEN_TOTAL_value' , 'counters_FILE_BYTES_READ_TOTAL_value' , 'counters_HDFS_BYTES_WRITTEN_TOTAL_value' , 'counters_VIRTUAL_MEMORY_BYTES_REDUCE_value' , 'counters_Latency_value' , 'counters_VIRTUAL_MEMORY_BYTES_TOTAL_value' , 'counters_FILE_BYTES_WRITTEN_TOTAL_value' , 'counters_PHYSICAL_MEMORY_BYTES_REDUCE_value' , 'counters_HDFS_BYTES_READ_TOTAL_value' , 'counters_CPU_MILLISECONDS_TOTAL_value' , 'counters_MB_MILLIS_REDUCES_TOTAL_value' , 'counters_VCORES_MILLIS_REDUCES_TOTAL_value' , 'conf_mapreduce_reduce_merge_inmem_threshold' , 'conf_mapreduce_reduce_cpu_vcores' , 'conf_java_heap_size_map' , 'conf_mapreduce_reduce_shuffle_input_buffer_percent' , 'conf_mapreduce_job_reduces' , 'conf_mapreduce_job_reduce_slowstart_completedmaps' , 'conf_mapreduce_reduce_shuffle_parallelcopies' , 'conf_mapreduce_task_io_sort_mb' , 'conf_mapreduce_map_cpu_vcores' , 'conf_mapreduce_tasktracker_indexcache_mb' , 'conf_mapreduce_reduce_shuffle_merge_percent' , 'conf_mapreduce_map_sort_spill_percent' , 'conf_mapreduce_map_memory_mb' , 'conf_mapreduce_reduce_input_buffer_percent' , 'conf_mapreduce_input_fileinputformat_split_maxsize' , 'conf_java_heap_size_reduce' , 'conf_mapreduce_reduce_memory_mb' , 'bestConf_mapreduce_reduce_merge_inmem_threshold' , 'bestConf_mapreduce_reduce_cpu_vcores' , 'bestConf_java_heap_size_map' , 'bestConf_mapreduce_reduce_shuffle_input_buffer_percent' , 'bestConf_mapreduce_job_reduces' , 'bestConf_mapreduce_job_reduce_slowstart_completedmaps' , 'bestConf_mapreduce_reduce_shuffle_parallelcopies' , 'bestConf_mapreduce_task_io_sort_mb' , 'bestConf_mapreduce_map_cpu_vcores' , 'bestConf_mapreduce_tasktracker_indexcache_mb' , 'bestConf_mapreduce_reduce_shuffle_merge_percent' , 'bestConf_mapreduce_map_sort_spill_percent' , 'bestConf_mapreduce_map_memory_mb' , 'bestConf_mapreduce_reduce_input_buffer_percent' , 'bestConf_mapreduce_input_fileinputformat_split_maxsize' , 'bestConf_java_heap_size_reduce' , 'bestConf_mapreduce_reduce_memory_mb' , 'originalConf_mapreduce_reduce_merge_inmem_threshold' , 'originalConf_mapreduce_reduce_cpu_vcores' , 'originalConf_java_heap_size_map' , 'originalConf_mapreduce_reduce_shuffle_input_buffer_percent' , 'originalConf_mapreduce_job_reduces' , 'originalConf_mapreduce_job_reduce_slowstart_completedmaps' , 'originalConf_mapreduce_reduce_shuffle_parallelcopies' , 'originalConf_mapreduce_task_io_sort_mb' , 'originalConf_mapreduce_map_cpu_vcores' , 'originalConf_mapreduce_tasktracker_indexcache_mb' , 'originalConf_mapreduce_reduce_shuffle_merge_percent' , 'originalConf_mapreduce_map_sort_spill_percent' , 'originalConf_mapreduce_map_memory_mb' , 'originalConf_mapreduce_reduce_input_buffer_percent' , 'originalConf_mapreduce_input_fileinputformat_split_maxsize' , 'originalConf_java_heap_size_reduce' , 'originalConf_mapreduce_reduce_memory_mb'])
 


def addthis(headerkey):
    global table
    global position
    global no_columns
    if headerkey in position:
        return
    else:
#        print headerkey
        table[0].append(headerkey)
        position[headerkey] = no_columns
        no_columns += 1


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
    table.append( [""] * (no_columns + 1) )
    for key in job:
        if isinstance(job[key],dict):
            for key2 in job[key]:
                if isinstance(job[key][key2],dict):
                    for key3 in job[key][key2]:
                        table[i][position[key + '_' + key2 + '_' + key3]] = job[key][key2][key3]
                else:
                    table[i][position[key + '_' + key2]] = job[key][key2]
        else:
            if key == 'allConfigs':
                table[i][position[key]] = ""
            else:
                table[i][position[key]] = job[key]


for row in table:
    if skipHeaderRow:
        skipHeaderRow = False
        continue
    s = ""
    firstItem = True
    pos = -1
    for element in row:
        pos += 1
        try:
            if table[0][pos] in columns:
#                print table[0][pos], " is included, in position ", pos 
                if firstItem:
                    firstItem = False
                else:
                    if table[0][pos] == "jobMetaData_finishTime" or table[0][pos] == "jobMetaData_startTime":
                        if str(element) == "":
                            s = ""
                            break
                    s += "\t"
#                s += '"' + str(element) + '"'
                s += str(element)
        except IndexError:
            pass
    if s != "" :
        print s, "\r"





                   

# columns = {"originator","attempts","isBestConfig","clusterID","clientSeqNo","jobMetaData_finishTime","jobMetaData_latency","jobMetaData_executionTime","jobMetaData_jobUrl","jobMetaData_jobID","jobMetaData_queue","jobMetaData_sherpaTuned","jobMetaData_tag","jobMetaData_computeEngineType","jobMetaData_costObjective","jobMetaData_startTime","jobMetaData_jobName","jobMetaData_user","state","cost","tunedParamsTypes","workloadID","allConfigs","tenzingSeqNo","_id","servedToClientCount","counters_MB_MILLIS_MAPS_MAP_value","counters_BYTES_READ_TOTAL_value","counters_HDFS_BYTES_WRITTEN_REDUCE_value","counters_VIRTUAL_MEMORY_BYTES_MAP_value","counters_Memory_Bytes_Seconds_value","counters_GC_TIME_MILLIS_TOTAL_value","counters_MB_MILLIS_MAPS_REDUCE_value","counters_HDFS_READ_OPS_TOTAL_value","counters_CPU_MILLISECONDS_REDUCE_value","counters_CPU_MILLISECONDS_MAP_value","counters_OTHER_LOCAL_MAPS_REDUCE_value","counters_SLOTS_MILLIS_MAPS_REDUCE_value","counters_HDFS_BYTES_READ_MAP_value","counters_HDFS_BYTES_WRITTEN_MAP_value","counters_VCORES_MILLIS_MAPS_TOTAL_value","counters_HDFS_LARGE_READ_OPS_REDUCE_value","counters_RECORDS_WRITTEN_MAP_value","counters_FILE_WRITE_OPS_REDUCE_value","counters_BYTES_WRITTEN_MAP_value","counters_OTHER_LOCAL_MAPS_TOTAL_value","counters_CPU_MILLISECONDS_value","counters_BYTES_READ_MAP_value","counters_PHYSICAL_MEMORY_BYTES_TOTAL_value","counters_SLOTS_MILLIS_MAPS_TOTAL_value","counters_FAILED_SHUFFLE_TOTAL_value","counters_GC_TIME_MILLIS_REDUCE_value","counters_FILE_READ_OPS_REDUCE_value","counters_SPLIT_RAW_BYTES_MAP_value","counters_PHYSICAL_MEMORY_BYTES_MAP_value","counters_HDFS_READ_OPS_REDUCE_value","counters_MAP_OUTPUT_RECORDS_REDUCE_value","counters_Execution_Time_value","counters_MAP_INPUT_RECORDS_TOTAL_value","counters_MILLIS_MAPS_TOTAL_value","counters_FILE_BYTES_READ_MAP_value","counters_FILE_LARGE_READ_OPS_TOTAL_value","counters_FILE_WRITE_OPS_MAP_value","counters_MB_MILLIS_MAPS_TOTAL_value","counters_HDFS_WRITE_OPS_TOTAL_value","counters_SPILLED_RECORDS_TOTAL_value","counters_BYTES_WRITTEN_TOTAL_value","counters_HDFS_BYTES_READ_REDUCE_value","counters_HDFS_LARGE_READ_OPS_MAP_value","counters_FILE_BYTES_READ_TOTAL_value","counters_MERGED_MAP_OUTPUTS_REDUCE_value","counters_HDFS_BYTES_WRITTEN_TOTAL_value","counters_FILE_BYTES_WRITTEN_REDUCE_value","counters_FAILED_SHUFFLE_MAP_value","counters_COMMITTED_HEAP_BYTES_MAP_value","counters_MILLIS_MAPS_REDUCE_value","counters_SPLIT_RAW_BYTES_TOTAL_value","counters_HDFS_WRITE_OPS_MAP_value","counters_MAP_OUTPUT_RECORDS_TOTAL_value","counters_HDFS_LARGE_READ_OPS_TOTAL_value","counters_FILE_READ_OPS_TOTAL_value","counters_VIRTUAL_MEMORY_BYTES_REDUCE_value","counters_MERGED_MAP_OUTPUTS_TOTAL_value","counters_SPILLED_RECORDS_MAP_value","counters_TOTAL_LAUNCHED_MAPS_TOTAL_value","counters_HDFS_WRITE_OPS_REDUCE_value","counters_OTHER_LOCAL_MAPS_MAP_value","counters_FILE_READ_OPS_MAP_value","counters_FILE_BYTES_WRITTEN_MAP_value","counters_COMMITTED_HEAP_BYTES_REDUCE_value","counters_GC_TIME_MILLIS_MAP_value","counters_RECORDS_WRITTEN_TOTAL_value","counters_BYTES_READ_REDUCE_value","counters_TOTAL_LAUNCHED_MAPS_MAP_value","counters_FILE_LARGE_READ_OPS_MAP_value","counters_MAP_INPUT_RECORDS_MAP_value","counters_TOTAL_LAUNCHED_MAPS_REDUCE_value","counters_MAP_OUTPUT_RECORDS_MAP_value","counters_FILE_BYTES_READ_REDUCE_value","counters_BYTES_WRITTEN_REDUCE_value","counters_MAP_INPUT_RECORDS_REDUCE_value","counters_FILE_LARGE_READ_OPS_REDUCE_value","counters_Latency_value","counters_VCORES_MILLIS_MAPS_MAP_value","counters_MILLIS_MAPS_MAP_value","counters_VIRTUAL_MEMORY_BYTES_TOTAL_value","counters_SPLIT_RAW_BYTES_REDUCE_value","counters_FILE_BYTES_WRITTEN_TOTAL_value","counters_PHYSICAL_MEMORY_BYTES_REDUCE_value","counters_RECORDS_WRITTEN_REDUCE_value","counters_VCORES_MILLIS_MAPS_REDUCE_value","counters_FILE_WRITE_OPS_TOTAL_value","counters_HDFS_BYTES_READ_TOTAL_value","counters_COMMITTED_HEAP_BYTES_TOTAL_value","counters_FAILED_SHUFFLE_REDUCE_value","counters_SPILLED_RECORDS_REDUCE_value","counters_CPU_MILLISECONDS_TOTAL_value","counters_MERGED_MAP_OUTPUTS_MAP_value","counters_HDFS_READ_OPS_MAP_value","counters_SLOTS_MILLIS_MAPS_MAP_value","counters_NUM_KILLED_MAPS_MAP_value","counters_NUM_KILLED_MAPS_TOTAL_value","counters_NUM_KILLED_MAPS_REDUCE_value","counters_BYTES_DATA_GENERATED_REDUCE_value","counters_REDUCE_INPUT_RECORDS_TOTAL_value","counters_MB_MILLIS_REDUCES_TOTAL_value","counters_BYTES_DATA_GENERATED_TOTAL_value","counters_MAP_OUTPUT_BYTES_MAP_value","counters_IO_ERROR_TOTAL_value","counters_CONNECTION_MAP_value","counters_BAD_ID_MAP_value","counters_COMBINE_INPUT_RECORDS_TOTAL_value","counters_SHUFFLED_MAPS_REDUCE_value","counters_REDUCE_OUTPUT_RECORDS_REDUCE_value","counters_WRONG_LENGTH_TOTAL_value","counters_WRONG_MAP_TOTAL_value","counters_COMBINE_OUTPUT_RECORDS_TOTAL_value","counters_REDUCE_SHUFFLE_BYTES_REDUCE_value","counters_WRONG_LENGTH_REDUCE_value","counters_MAP_OUTPUT_BYTES_TOTAL_value","counters_BAD_ID_REDUCE_value","counters_REDUCE_INPUT_RECORDS_MAP_value","counters_TOTAL_LAUNCHED_REDUCES_TOTAL_value","counters_WRONG_REDUCE_REDUCE_value","counters_WRONG_LENGTH_MAP_value","counters_REDUCE_OUTPUT_RECORDS_MAP_value","counters_REDUCE_INPUT_GROUPS_MAP_value","counters_MILLIS_REDUCES_MAP_value","counters_SHUFFLED_MAPS_MAP_value","counters_REDUCE_SHUFFLE_BYTES_TOTAL_value","counters_BAD_ID_TOTAL_value","counters_MB_MILLIS_REDUCES_REDUCE_value","counters_MAP_OUTPUT_MATERIALIZED_BYTES_MAP_value","counters_VCORES_MILLIS_REDUCES_REDUCE_value","counters_MILLIS_REDUCES_REDUCE_value","counters_MAP_OUTPUT_MATERIALIZED_BYTES_TOTAL_value","counters_WRONG_MAP_REDUCE_value","counters_SHUFFLED_MAPS_TOTAL_value","counters_CONNECTION_REDUCE_value","counters_VCORES_MILLIS_REDUCES_TOTAL_value","counters_MAP_OUTPUT_BYTES_REDUCE_value","counters_WRONG_REDUCE_TOTAL_value","counters_REDUCE_INPUT_GROUPS_REDUCE_value","counters_REDUCE_OUTPUT_RECORDS_TOTAL_value","counters_IO_ERROR_MAP_value","counters_CONNECTION_TOTAL_value","counters_MILLIS_REDUCES_TOTAL_value","counters_COMBINE_OUTPUT_RECORDS_REDUCE_value","counters_TOTAL_LAUNCHED_REDUCES_REDUCE_value","counters_IO_ERROR_REDUCE_value","counters_MAP_OUTPUT_MATERIALIZED_BYTES_REDUCE_value","counters_WRONG_REDUCE_MAP_value","counters_REDUCE_INPUT_RECORDS_REDUCE_value","counters_SLOTS_MILLIS_REDUCES_MAP_value","counters_VCORES_MILLIS_REDUCES_MAP_value","counters_WRONG_MAP_MAP_value","counters_MB_MILLIS_REDUCES_MAP_value","counters_SLOTS_MILLIS_REDUCES_REDUCE_value","counters_BYTES_DATA_GENERATED_MAP_value","counters_COMBINE_OUTPUT_RECORDS_MAP_value","counters_TOTAL_LAUNCHED_REDUCES_MAP_value","counters_REDUCE_SHUFFLE_BYTES_MAP_value","counters_COMBINE_INPUT_RECORDS_MAP_value","counters_COMBINE_INPUT_RECORDS_REDUCE_value","counters_REDUCE_INPUT_GROUPS_TOTAL_value","counters_SLOTS_MILLIS_REDUCES_TOTAL_value","counters_DATA_LOCAL_MAPS_REDUCE_value","counters_DATA_LOCAL_MAPS_TOTAL_value","counters_DATA_LOCAL_MAPS_MAP_value","counters_CHECKSUM_REDUCE_value","counters_CHECKSUM_TOTAL_value","counters_CHECKSUM_MAP_value","counters_RACK_LOCAL_MAPS_TOTAL_value","counters_RACK_LOCAL_MAPS_REDUCE_value","counters_RACK_LOCAL_MAPS_MAP_value","conf_mapreduce_reduce_merge_inmem_threshold","conf_mapreduce_reduce_cpu_vcores","conf_java_heap_size_map","conf_mapreduce_reduce_shuffle_input_buffer_percent","conf_mapreduce_job_reduces","conf_mapreduce_job_reduce_slowstart_completedmaps","conf_mapreduce_reduce_shuffle_parallelcopies","conf_mapreduce_task_io_sort_mb","conf_mapreduce_map_cpu_vcores","conf_mapreduce_tasktracker_indexcache_mb","conf_mapreduce_reduce_shuffle_merge_percent","conf_mapreduce_map_sort_spill_percent","conf_mapreduce_map_memory_mb","conf_mapreduce_reduce_input_buffer_percent","conf_mapreduce_input_fileinputformat_split_maxsize","conf_java_heap_size_reduce","conf_mapreduce_reduce_memory_mb","counters_NUM_KILLED_REDUCES_REDUCE_value","counters_NUM_KILLED_REDUCES_MAP_value","counters_NUM_KILLED_REDUCES_TOTAL_value","bestConf_mapreduce_reduce_merge_inmem_threshold","bestConf_mapreduce_reduce_cpu_vcores","bestConf_java_heap_size_map","bestConf_mapreduce_reduce_shuffle_input_buffer_percent","bestConf_mapreduce_job_reduces","bestConf_mapreduce_job_reduce_slowstart_completedmaps","bestConf_mapreduce_reduce_shuffle_parallelcopies","bestConf_mapreduce_task_io_sort_mb","bestConf_mapreduce_map_cpu_vcores","bestConf_mapreduce_tasktracker_indexcache_mb","bestConf_mapreduce_reduce_shuffle_merge_percent","bestConf_mapreduce_map_sort_spill_percent","bestConf_mapreduce_map_memory_mb","bestConf_mapreduce_reduce_input_buffer_percent","bestConf_mapreduce_input_fileinputformat_split_maxsize","bestConf_java_heap_size_reduce","bestConf_mapreduce_reduce_memory_mb","counters_NUM_FAILED_REDUCES_REDUCE_value","counters_NUM_FAILED_REDUCES_TOTAL_value","counters_NUM_FAILED_REDUCES_MAP_value","counters_CREATED_FILES_TOTAL_value","counters_RECORDS_IN_REDUCE_value","counters_RECORDS_OUT_INTERMEDIATE_REDUCE_value","counters_CREATED_FILES_REDUCE_value","counters_RECORDS_OUT_INTERMEDIATE_MAP_value","counters_RECORDS_OUT_1_default_rankings_uservisits_join_REDUCE_value","counters_RECORDS_OUT_0_REDUCE_value","counters_RECORDS_OUT_1_default_rankings_uservisits_join_TOTAL_value","counters_RECORDS_OUT_INTERMEDIATE_TOTAL_value","counters_CREATED_FILES_MAP_value","counters_DESERIALIZE_ERRORS_TOTAL_value","counters_RECORDS_OUT_1_default_rankings_uservisits_join_MAP_value","counters_RECORDS_IN_MAP_value","counters_DESERIALIZE_ERRORS_REDUCE_value","counters_SKEWJOINFOLLOWUPJOBS_MAP_value","counters_RECORDS_OUT_0_MAP_value","counters_DESERIALIZE_ERRORS_MAP_value","counters_RECORDS_OUT_0_TOTAL_value","counters_SKEWJOINFOLLOWUPJOBS_REDUCE_value","counters_SKEWJOINFOLLOWUPJOBS_TOTAL_value","counters_RECORDS_IN_TOTAL_value","originalConf_mapreduce_reduce_merge_inmem_threshold","originalConf_mapreduce_reduce_cpu_vcores","originalConf_java_heap_size_map","originalConf_mapreduce_reduce_shuffle_input_buffer_percent","originalConf_mapreduce_job_reduces","originalConf_mapreduce_job_reduce_slowstart_completedmaps","originalConf_mapreduce_reduce_shuffle_parallelcopies","originalConf_mapreduce_task_io_sort_mb","originalConf_mapreduce_map_cpu_vcores","originalConf_mapreduce_tasktracker_indexcache_mb","originalConf_mapreduce_reduce_shuffle_merge_percent","originalConf_mapreduce_map_sort_spill_percent","originalConf_mapreduce_map_memory_mb","originalConf_mapreduce_reduce_input_buffer_percent","originalConf_mapreduce_input_fileinputformat_split_maxsize","originalConf_java_heap_size_reduce","originalConf_mapreduce_reduce_memory_mb"}

