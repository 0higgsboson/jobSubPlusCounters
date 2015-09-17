package com.sherpa.core.dao;

import java.math.BigInteger;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by akhtar on 22/08/2015.
 */
public class HiBenchCountersConfigurations {

    public static final String JOB_TYPE_HIVE="hive";
    public static final String JOB_TYPE_MR="mr";
    public static final String JOB_TYPE_SPARK="spark";


    public static final String MEMORY_COLUMN_NAME="memory";
    public static final String CPU_COLUMN_NAME="cpu";
    public static final String JOB_TIME_COLUMN_NAME="job_time";


    public static final String TABLE_NAME = "workloadCounters";
    public static final String DATA_COLUMN_FAMILY = "counters";


    public static final String COUNTERS_TABLE_NAME = "hibench";
    public static final String WORKLOAD_IDS_TABLE_NAME = "hibenchIds";

    public static final String RECORD_ID = "RECORD_ID";
    public static final String PARAMETERS = "PARAMETERS";
    public static final String QUERY = "QUERY";

    public static final String[] columnNamesTypesList = new String[]{
    	
            "CONFIG_REDUCERS:BIGINT", 
            "CONFIG_MAPPERS:BIGINT",
            "CONFIG_REDUCERS_MEMORY:BIGINT", 
            "CONFIG_MAPPERS_MEMORY:BIGINT",
            "CONFIG_REDUCE_CORES:BIGINT", 
            "CONFIG_MAP_CORES:BIGINT",
            
            "AVG_REDUCE_TIME:BIGINT", 
            "AVG_MAP_TIME:BIGINT",

            "TOTAL_REDUCERS:BIGINT", 
            "TOTAL_MAPPERS:BIGINT",
            "REDUCE_TIME:BIGINT", 
            "MAP_TIME:BIGINT",
            "REDUCE_VCORE_TIME:BIGINT", 
            "MAP_VCORE_TIME:BIGINT",
            "MAP_PHYSICAL_MEM_BYTES:BIGINT", 
            "MAP_PHYSICAL_MEM_MB:BIGINT",
            "MAP_VIRTUAL_MEM_BYTES:BIGINT", 
            "MAP_VIRTUAL_MEM_MB:BIGINT",
            "REDUCE_VIRTUAL_MEM:BIGINT", 
            "REDUCE_PHYSICAL_MEM:BIGINT",
            /* EK: Would like to see these counters
            "MB_MILLIS_MAPS:BIGINT", 
            "MB_MILLIS_REDUCES:BIGINT",
            "VCORES_MILLIS_MAPS:BIGINT",
            "VCORES_MILLIS_REDUCES:BIGINT",
            */
            "NUMBER_OF_FILES:BIGINT", 
            "AVG_FILE_SIZE:BIGINT"

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

    //public static void main(String[] args){
     //   System.out.print(getWorkloadIdsTableSchema());
    //}


}
