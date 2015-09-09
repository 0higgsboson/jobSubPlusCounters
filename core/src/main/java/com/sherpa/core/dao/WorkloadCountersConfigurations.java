package com.sherpa.core.dao;

import java.math.BigInteger;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by akhtar on 22/08/2015.
 */
public class WorkloadCountersConfigurations {

    public static final String JOB_TYPE_HIVE="hive";
    public static final String JOB_TYPE_MR="mr";
    public static final String JOB_TYPE_SPARK="spark";


    public static final String MEMORY_COLUMN_NAME="memory";
    public static final String CPU_COLUMN_NAME="cpu";
    public static final String JOB_TIME_COLUMN_NAME="job_time";


    public static final String TABLE_NAME = "workloadCounters";
    public static final String DATA_COLUMN_FAMILY = "counters";


    public static final String COUNTERS_TABLE_NAME = "counters";
    public static final String WORKLOAD_IDS_TABLE_NAME = "workloadIds";



    public static final String[] columnNamesTypesList = new String[]{

            "FileSystemCounter_FILE_BYTES_READ:BIGINT", "FileSystemCounter_FILE_BYTES_WRITTEN:BIGINT",
            "FileSystemCounter_FILE_READ_OPS:BIGINT", "FileSystemCounter_FILE_LARGE_READ_OPS:BIGINT",
            "FileSystemCounter_FILE_WRITE_OPS:BIGINT", "FileSystemCounter_HDFS_BYTES_READ:BIGINT",
            "FileSystemCounter_HDFS_BYTES_WRITTEN:BIGINT", "FileSystemCounter_HDFS_READ_OPS:BIGINT",
            "FileSystemCounter_HDFS_LARGE_READ_OPS:BIGINT", "FileSystemCounter_HDFS_WRITE_OPS:BIGINT",

            "TaskCounter_COMBINE_INPUT_RECORDS:BIGINT", "TaskCounter_COMBINE_OUTPUT_RECORDS:BIGINT",
            "TaskCounter_REDUCE_INPUT_GROUPS:BIGINT", "TaskCounter_REDUCE_SHUFFLE_BYTES:BIGINT",
            "TaskCounter_REDUCE_INPUT_RECORDS:BIGINT", "TaskCounter_REDUCE_OUTPUT_RECORDS:BIGINT",
            "TaskCounter_SPILLED_RECORDS:BIGINT", "TaskCounter_SHUFFLED_MAPS:BIGINT",
            "TaskCounter_FAILED_SHUFFLE:BIGINT", "TaskCounter_MERGED_MAP_OUTPUTS:BIGINT",
            "TaskCounter_GC_TIME_MILLIS:BIGINT", "TaskCounter_CPU_MILLISECONDS:BIGINT",
            "TaskCounter_PHYSICAL_MEMORY_BYTES:BIGINT", "TaskCounter_VIRTUAL_MEMORY_BYTES:BIGINT",
            "TaskCounter_MAP_INPUT_RECORDS:BIGINT", "TaskCounter_MAP_OUTPUT_RECORDS:BIGINT",
            "TaskCounter_MAP_OUTPUT_BYTES:BIGINT", "TaskCounter_MAP_OUTPUT_MATERIALIZED_BYTES:BIGINT",
            "TaskCounter_COMMITTED_HEAP_BYTES:BIGINT","TaskCounter_SPLIT_RAW_BYTES:BIGINT",

            "ShuffleErrors_BAD_ID:BIGINT", "ShuffleErrors_CONNECTION:BIGINT",
            "ShuffleErrors_IO_ERROR:BIGINT", "ShuffleErrors_WRONG_LENGTH:BIGINT",
            "ShuffleErrors_WRONG_MAP:BIGINT", "ShuffleErrors_WRONG_REDUCE:BIGINT"




    };


    public static Map<String, BigInteger> getInitialCounterValuesMap(){
        Map<String, BigInteger> map = new HashMap<String, BigInteger>();

        String tok[];
        for(int i=0; i<columnNamesTypesList.length; i++){
            tok = columnNamesTypesList[i].split(":");
            map.put(tok[0], new BigInteger("0"));
        }

        return map;
    }



    public static String getCountersTableSchema(){
        String tok[];
        String schema = "CREATE TABLE IF NOT EXISTS " +
                COUNTERS_TABLE_NAME +
                " ( WORKLOAD_ID INTEGER not null, DATE_TIME Date not null, JOB_ID VARCHAR  not null, EXECUTION_TIME INTEGER, JOB_TYPE VARCHAR ";

        for(int i=0; i<columnNamesTypesList.length; i++){
            tok = columnNamesTypesList[i].split(":");
            schema += "," + tok[0] + " " + tok[1] + " ";
        }

        schema += " CONSTRAINT pk PRIMARY KEY (WORKLOAD_ID, DATE_TIME, JOB_ID) )";

        return schema;
    }



    public static String getWorkloadIdsTableSchema(){
        String schema = "CREATE TABLE IF NOT EXISTS " +
                WORKLOAD_IDS_TABLE_NAME +
                " ( WORKLOAD_ID INTEGER not null, DATE_TIME Date, HASH BIGINT ";

        schema += " CONSTRAINT pk PRIMARY KEY (WORKLOAD_ID) )";

        return schema;
    }




    public static void main(String[] args){
        System.out.print(getWorkloadIdsTableSchema());
    }









}
