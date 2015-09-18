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

    public static final String RECORD_ID = "RECORD_ID";
    public static final String PARAMETERS = "PARAMETERS";
    public static final String QUERY = "QUERY";

        public static final String MAP_SUFFIX = "_MAP";
        public static final String REDUCE_SUFFIX = "_REDUCE";
        public static final String TOTAL_SUFFIX = "_TOTAL";



    public static final String[] columnNamesTypesList = new String[]{

            "FILE_BYTES_READ_MAP:BIGINT"
            ,"FILE_BYTES_READ_REDUCE:BIGINT"
            ,"FILE_BYTES_READ_TOTAL:BIGINT"
            ,"FILE_BYTES_WRITTEN_MAP:BIGINT"
            ,"FILE_BYTES_WRITTEN_REDUCE:BIGINT"
            ,"FILE_BYTES_WRITTEN_TOTAL:BIGINT"
            ,"FILE_READ_OPS_MAP:BIGINT"
            ,"FILE_READ_OPS_REDUCE:BIGINT"
            ,"FILE_READ_OPS_TOTAL:BIGINT"
            ,"FILE_LARGE_READ_OPS_MAP:BIGINT"
            ,"FILE_LARGE_READ_OPS_REDUCE:BIGINT"
            ,"FILE_LARGE_READ_OPS_TOTAL:BIGINT"
            ,"FILE_WRITE_OPS_MAP:BIGINT"
            ,"FILE_WRITE_OPS_REDUCE:BIGINT"
            ,"FILE_WRITE_OPS_TOTAL:BIGINT"
            ,"HDFS_BYTES_READ_MAP:BIGINT"
            ,"HDFS_BYTES_READ_REDUCE:BIGINT"
            ,"HDFS_BYTES_READ_TOTAL:BIGINT"
            ,"HDFS_BYTES_WRITTEN_MAP:BIGINT"
            ,"HDFS_BYTES_WRITTEN_REDUCE:BIGINT"
            ,"HDFS_BYTES_WRITTEN_TOTAL:BIGINT"
            ,"HDFS_READ_OPS_MAP:BIGINT"
            ,"HDFS_READ_OPS_REDUCE:BIGINT"
            ,"HDFS_READ_OPS_TOTAL:BIGINT"
            ,"HDFS_LARGE_READ_OPS_MAP:BIGINT"
            ,"HDFS_LARGE_READ_OPS_REDUCE:BIGINT"
            ,"HDFS_LARGE_READ_OPS_TOTAL:BIGINT"
            ,"HDFS_WRITE_OPS_MAP:BIGINT"
            ,"HDFS_WRITE_OPS_REDUCE:BIGINT"
            ,"HDFS_WRITE_OPS_TOTAL:BIGINT"
            ,"TOTAL_LAUNCHED_MAPS_MAP:BIGINT"
            ,"TOTAL_LAUNCHED_MAPS_REDUCE:BIGINT"
            ,"TOTAL_LAUNCHED_MAPS_TOTAL:BIGINT"
            ,"TOTAL_LAUNCHED_REDUCES_MAP:BIGINT"
            ,"TOTAL_LAUNCHED_REDUCES_REDUCE:BIGINT"
            ,"TOTAL_LAUNCHED_REDUCES_TOTAL:BIGINT"
            ,"DATA_LOCAL_MAPS_MAP:BIGINT"
            ,"DATA_LOCAL_MAPS_REDUCE:BIGINT"
            ,"DATA_LOCAL_MAPS_TOTAL:BIGINT"
            ,"RACK_LOCAL_MAPS_MAP:BIGINT"
            ,"RACK_LOCAL_MAPS_REDUCE:BIGINT"
            ,"RACK_LOCAL_MAPS_TOTAL:BIGINT"
            ,"SLOTS_MILLIS_MAPS_MAP:BIGINT"
            ,"SLOTS_MILLIS_MAPS_REDUCE:BIGINT"
            ,"SLOTS_MILLIS_MAPS_TOTAL:BIGINT"
            ,"SLOTS_MILLIS_REDUCES_MAP:BIGINT"
            ,"SLOTS_MILLIS_REDUCES_REDUCE:BIGINT"
            ,"SLOTS_MILLIS_REDUCES_TOTAL:BIGINT"
            ,"MILLIS_MAPS_MAP:BIGINT"
            ,"MILLIS_MAPS_REDUCE:BIGINT"
            ,"MILLIS_MAPS_TOTAL:BIGINT"
            ,"MILLIS_REDUCES_MAP:BIGINT"
            ,"MILLIS_REDUCES_REDUCE:BIGINT"
            ,"MILLIS_REDUCES_TOTAL:BIGINT"
            ,"VCORES_MILLIS_MAPS_MAP:BIGINT"
            ,"VCORES_MILLIS_MAPS_REDUCE:BIGINT"
            ,"VCORES_MILLIS_MAPS_TOTAL:BIGINT"
            ,"VCORES_MILLIS_REDUCES_MAP:BIGINT"
            ,"VCORES_MILLIS_REDUCES_REDUCE:BIGINT"
            ,"VCORES_MILLIS_REDUCES_TOTAL:BIGINT"
            ,"MB_MILLIS_MAPS_MAP:BIGINT"
            ,"MB_MILLIS_MAPS_REDUCE:BIGINT"
            ,"MB_MILLIS_MAPS_TOTAL:BIGINT"
            ,"MB_MILLIS_REDUCES_MAP:BIGINT"
            ,"MB_MILLIS_REDUCES_REDUCE:BIGINT"
            ,"MB_MILLIS_REDUCES_TOTAL:BIGINT"
            ,"MAP_INPUT_RECORDS_MAP:BIGINT"
            ,"MAP_INPUT_RECORDS_REDUCE:BIGINT"
            ,"MAP_INPUT_RECORDS_TOTAL:BIGINT"
            ,"MAP_OUTPUT_RECORDS_MAP:BIGINT"
            ,"MAP_OUTPUT_RECORDS_REDUCE:BIGINT"
            ,"MAP_OUTPUT_RECORDS_TOTAL:BIGINT"
            ,"MAP_OUTPUT_BYTES_MAP:BIGINT"
            ,"MAP_OUTPUT_BYTES_REDUCE:BIGINT"
            ,"MAP_OUTPUT_BYTES_TOTAL:BIGINT"
            ,"MAP_OUTPUT_MATERIALIZED_BYTES_MAP:BIGINT"
            ,"MAP_OUTPUT_MATERIALIZED_BYTES_REDUCE:BIGINT"
            ,"MAP_OUTPUT_MATERIALIZED_BYTES_TOTAL:BIGINT"
            ,"SPLIT_RAW_BYTES_MAP:BIGINT"
            ,"SPLIT_RAW_BYTES_REDUCE:BIGINT"
            ,"SPLIT_RAW_BYTES_TOTAL:BIGINT"
            ,"COMBINE_INPUT_RECORDS_MAP:BIGINT"
            ,"COMBINE_INPUT_RECORDS_REDUCE:BIGINT"
            ,"COMBINE_INPUT_RECORDS_TOTAL:BIGINT"
            ,"COMBINE_OUTPUT_RECORDS_MAP:BIGINT"
            ,"COMBINE_OUTPUT_RECORDS_REDUCE:BIGINT"
            ,"COMBINE_OUTPUT_RECORDS_TOTAL:BIGINT"
            ,"REDUCE_INPUT_GROUPS_MAP:BIGINT"
            ,"REDUCE_INPUT_GROUPS_REDUCE:BIGINT"
            ,"REDUCE_INPUT_GROUPS_TOTAL:BIGINT"
            ,"REDUCE_SHUFFLE_BYTES_MAP:BIGINT"
            ,"REDUCE_SHUFFLE_BYTES_REDUCE:BIGINT"
            ,"REDUCE_SHUFFLE_BYTES_TOTAL:BIGINT"
            ,"REDUCE_INPUT_RECORDS_MAP:BIGINT"
            ,"REDUCE_INPUT_RECORDS_REDUCE:BIGINT"
            ,"REDUCE_INPUT_RECORDS_TOTAL:BIGINT"
            ,"REDUCE_OUTPUT_RECORDS_MAP:BIGINT"
            ,"REDUCE_OUTPUT_RECORDS_REDUCE:BIGINT"
            ,"REDUCE_OUTPUT_RECORDS_TOTAL:BIGINT"
            ,"SPILLED_RECORDS_MAP:BIGINT"
            ,"SPILLED_RECORDS_REDUCE:BIGINT"
            ,"SPILLED_RECORDS_TOTAL:BIGINT"
            ,"SHUFFLED_MAPS_MAP:BIGINT"
            ,"SHUFFLED_MAPS_REDUCE:BIGINT"
            ,"SHUFFLED_MAPS_TOTAL:BIGINT"
            ,"FAILED_SHUFFLE_MAP:BIGINT"
            ,"FAILED_SHUFFLE_REDUCE:BIGINT"
            ,"FAILED_SHUFFLE_TOTAL:BIGINT"
            ,"MERGED_MAP_OUTPUTS_MAP:BIGINT"
            ,"MERGED_MAP_OUTPUTS_REDUCE:BIGINT"
            ,"MERGED_MAP_OUTPUTS_TOTAL:BIGINT"
            ,"GC_TIME_MILLIS_MAP:BIGINT"
            ,"GC_TIME_MILLIS_REDUCE:BIGINT"
            ,"GC_TIME_MILLIS_TOTAL:BIGINT"
            ,"CPU_MILLISECONDS_MAP:BIGINT"
            ,"CPU_MILLISECONDS_REDUCE:BIGINT"
            ,"CPU_MILLISECONDS_TOTAL:BIGINT"
            ,"PHYSICAL_MEMORY_BYTES_MAP:BIGINT"
            ,"PHYSICAL_MEMORY_BYTES_REDUCE:BIGINT"
            ,"PHYSICAL_MEMORY_BYTES_TOTAL:BIGINT"
            ,"VIRTUAL_MEMORY_BYTES_MAP:BIGINT"
            ,"VIRTUAL_MEMORY_BYTES_REDUCE:BIGINT"
            ,"VIRTUAL_MEMORY_BYTES_TOTAL:BIGINT"
            ,"COMMITTED_HEAP_BYTES_MAP:BIGINT"
            ,"COMMITTED_HEAP_BYTES_REDUCE:BIGINT"
            ,"COMMITTED_HEAP_BYTES_TOTAL:BIGINT"
            ,"CREATED_FILES_MAP:BIGINT"
            ,"CREATED_FILES_REDUCE:BIGINT"
            ,"CREATED_FILES_TOTAL:BIGINT"
            ,"DESERIALIZE_ERRORS_MAP:BIGINT"
            ,"DESERIALIZE_ERRORS_REDUCE:BIGINT"
            ,"DESERIALIZE_ERRORS_TOTAL:BIGINT"
            ,"RECORDS_IN_MAP:BIGINT"
            ,"RECORDS_IN_REDUCE:BIGINT"
            ,"RECORDS_IN_TOTAL:BIGINT"
            ,"RECORDS_OUT_MAP:BIGINT"
            ,"RECORDS_OUT_REDUCE:BIGINT"
            ,"RECORDS_OUT_TOTAL:BIGINT"
            ,"RECORDS_OUT_INTERMEDIATE_MAP:BIGINT"
            ,"RECORDS_OUT_INTERMEDIATE_REDUCE:BIGINT"
            ,"RECORDS_OUT_INTERMEDIATE_TOTAL:BIGINT"
            ,"BAD_ID_MAP:BIGINT"
            ,"BAD_ID_REDUCE:BIGINT"
            ,"BAD_ID_TOTAL:BIGINT"
            ,"CONNECTION_MAP:BIGINT"
            ,"CONNECTION_REDUCE:BIGINT"
            ,"CONNECTION_TOTAL:BIGINT"
            ,"IO_ERROR_MAP:BIGINT"
            ,"IO_ERROR_REDUCE:BIGINT"
            ,"IO_ERROR_TOTAL:BIGINT"
            ,"WRONG_LENGTH_MAP:BIGINT"
            ,"WRONG_LENGTH_REDUCE:BIGINT"
            ,"WRONG_LENGTH_TOTAL:BIGINT"
            ,"WRONG_MAP_MAP:BIGINT"
            ,"WRONG_MAP_REDUCE:BIGINT"
            ,"WRONG_MAP_TOTAL:BIGINT"
            ,"WRONG_REDUCE_MAP:BIGINT"
            ,"WRONG_REDUCE_REDUCE:BIGINT"
            ,"WRONG_REDUCE_TOTAL:BIGINT"
            ,"BYTES_READ_MAP:BIGINT"
            ,"BYTES_READ_REDUCE:BIGINT"
            ,"BYTES_READ_TOTAL:BIGINT"
            ,"BYTES_WRITTEN_MAP:BIGINT"
            ,"BYTES_WRITTEN_REDUCE:BIGINT"
            ,"BYTES_WRITTEN_TOTAL:BIGINT"



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
                " ( WORKLOAD_ID INTEGER not null, DATE_TIME Date not null, JOB_ID VARCHAR not null, EXECUTION_TIME INTEGER, JOB_TYPE VARCHAR, PARAMETERS VARCHAR";

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

    //public static void main(String[] args){
     //   System.out.print(getWorkloadIdsTableSchema());
    //}

}
