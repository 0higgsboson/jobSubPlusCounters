#!/bin/bash

now=$(date +"%Y_%d_%m_%H_%M_%s")
examplesJar="/root/cluster/hadoop/hadoop-2.7.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar"
echo "Output directory name : /nas/backup_$now.sql"
# yarn jar /root/sherpa-old/hadoop_src/hadoop-2.7.1-src/hadoop-mapreduce-project/target/hadoop-mapreduce-2.7.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.1.jar wordcount -D PSManaged=true -D Tag=wordcount-MR-example-0075 /input/ /output/$now 
# yarn jar $examplesJar terasort -D PSManaged=false -D Tag=terasort-small-best  -D mapreduce_reduce_shuffle_parallelcopies=5 -D mapreduce_reduce_cpu_vcores=1 -D java_heap_size_map=72 -D mapreduce_reduce_shuffle_input_buffer_percent=0.6601785227336726 -D mapreduce_job_reduces=1 -D mapreduce_job_reduce_slowstart_completedmaps=0.32867665085183007 -D mapreduce_reduce_merge_inmem_threshold=5883 -D mapreduce_task_io_sort_mb=1 -D mapreduce_map_cpu_vcores=1 -D mapreduce_tasktracker_indexcache_mb=1 -D mapreduce_reduce_shuffle_merge_percent=0.8056188276237622 -D mapreduce_map_sort_spill_percent=0.7813895650254963 -D mapreduce_map_memory_mb=128 -D mapreduce_reduce_input_buffer_percent=0.09846443576223042 -D mapreduce_input_fileinputformat_split_maxsize=50000000 -D java_heap_size_reduce=80 -D mapreduce_reduce_memory_mb=128 /tsinput-small/ /tsoutput/$now 
yarn jar $examplesJar terasort -D PSManaged=false -D Tag=terasort-small-best  -D mapreduce_map_memory_mb=128 -D mapreduce_reduce_memory_mb=128 /tsinput-small/ /tsoutput/$now 
hadoop fs -rm /tsoutput/$now/*

