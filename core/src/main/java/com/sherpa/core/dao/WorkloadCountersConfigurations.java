package com.sherpa.core.dao;

import java.math.BigInteger;
import java.util.*;

/**
 * Created by akhtar on 22/08/2015.
 */

public class WorkloadCountersConfigurations {

        public static final String COMPUTE_ENGINE_HIVE ="hive";
        public static final String COMPUTE_ENGINE_MR ="mr";
        public static final String COMPUTE_ENGINE_SPARK ="spark";

        public static final String COUNTERS_TABLE_NAME = "workloads";
        public static final String WORKLOAD_IDS_TABLE_NAME = "workloadIds";

        public static final String RECORD_ID = "RECORD_ID";
        public static final String QUERY = "QUERY";

        public static final String MAP_SUFFIX = "_MAP";
        public static final String REDUCE_SUFFIX = "_REDUCE";
        public static final String TOTAL_SUFFIX = "_TOTAL";


        public static final String COLUMN_WORKLOAD_ID       = "WORKLOAD_ID";
        public static final String COLUMN_JOB_ID            = "JOB_ID";
        public static final String COLUMN_EXECUTION_TIME    = "EXECUTION_TIME";
        public static final String COLUMN_JOB_URL           = "JOB_URL";
        public static final String COLUMN_START_TIME        = "START_TIME";
        public static final String COLUMN_END_TIME          = "END_TIME";
        public static final String COLUMN_COUNTERS          = "COUNTERS";
        public static final String COLUMN_USER              = "USER";
        public static final String COLUMN_QUEUE             = "QUEUE";
        public static final String COLUMN_CLUSTER_ID        = "CLUSTER_ID";
        public static final String COLUMN_SHERPA_TUNED      = "SHERPA_TUNED";
        public static final String COLUMN_TAG                      = "TAG";
        public static final String COLUMN_ORIGIN            = "ORIGIN";
        public static final String COLUMN_CONFIGURATIONS    = "CONFIGURATIONS";
        public static final String COLUMN_COMPUTE_ENGINE_TYPE            = "COMPUTE_ENGINE_TYPE";
        public static final String COLUMN_LATENCY            = "LATENCY";



    public static final String[] PARAMETERS = new String[]{
            "mapreduce_max_split_size:VARCHAR",
            "mapreduce_job_reduces:VARCHAR",
            "mapreduce_map_memory_mb:VARCHAR",
            "mapreduce_reduce_memory_mb:VARCHAR",
            "mapreduce_map_cpu_vcores:VARCHAR",
            "mapreduce_reduce_cpu_vcores:VARCHAR"

            ,"mapreduce_task_io_sort_mb:VARCHAR"
            ,"mapreduce_map_sort_spill_percent:VARCHAR"
            ,"mapreduce_reduce_input_buffer_percent:VARCHAR"
            ,"mapreduce_reduce_merge_inmem_threshold:VARCHAR"
            ,"mapreduce_job_reduce_slowstart_completedmaps:VARCHAR"
            ,"mapreduce_reduce_shuffle_merge_percent:VARCHAR"
            ,"mapreduce_reduce_shuffle_parallelcopies:VARCHAR"
            ,"mapreduce_reduce_shuffle_input_buffer_percent:VARCHAR"
            ,"mapreduce_tasktracker_indexcache_mb:VARCHAR"

            ,"java_heap_size_map:VARCHAR"
            ,"java_heap_size_reduce:VARCHAR"


    };




        public static final String[] ACCEPTED_PARAMETERS = new String[]{
                "accepted_mapreduce_job_maps:BIGINT",
                "accepted_mapreduce_job_reduces:BIGINT",
                "accepted_mapreduce_map_memory_mb:BIGINT",
                "accepted_mapreduce_reduce_memory_mb:BIGINT",
                "accepted_mapreduce_map_cpu_vcores:BIGINT",
                "accepted_mapreduce_reduce_cpu_vcores:BIGINT",
        };


    public static final String[] COUNTERS = new String[]{
             "PHYSICAL_MEMORY_BYTES_MAP:BIGINT"
             ,"PHYSICAL_MEMORY_BYTES_REDUCE:BIGINT"
             ,"MB_MILLIS_MAPS:BIGINT"
             ,"MB_MILLIS_REDUCES:BIGINT"
             ,"CPU_MILLISECONDS_MAP:BIGINT"
             ,"CPU_MILLISECONDS_REDUCE:BIGINT"
             ,"HDFS_BYTES_READ:BIGINT"
             ,"HDFS_BYTES_WRITTEN:BIGINT"

            ,"VCORES_MILLIS_MAPS:BIGINT"
            ,"VCORES_MILLIS_REDUCES:BIGINT"

            ,"MILLIS_MAPS:BIGINT"
             ,"MILLIS_REDUCES:BIGINT"

        };




        public static Map<String, String> getColumnNameTypeMap(){
            Map<String, String> map = new HashMap<String, String>();
            map.put(COLUMN_WORKLOAD_ID,"VARCHAR not null");
            map.put(COLUMN_START_TIME,"VARCHAR not null");
            map.put(COLUMN_JOB_ID,"VARCHAR not null");
            map.put(COLUMN_EXECUTION_TIME,"INTEGER");
            map.put(COLUMN_JOB_URL,"VARCHAR");
            map.put(COLUMN_END_TIME,"VARCHAR");
            map.put(COLUMN_COUNTERS,"VARCHAR");

            map.put(COLUMN_USER,"VARCHAR");
            map.put(COLUMN_QUEUE,"VARCHAR");
            map.put(COLUMN_CLUSTER_ID,"VARCHAR");
            map.put(COLUMN_SHERPA_TUNED,"VARCHAR");
            map.put(COLUMN_TAG,"VARCHAR");
            map.put(COLUMN_ORIGIN,"VARCHAR");

            map.put(COLUMN_CONFIGURATIONS,"VARCHAR");
            map.put(COLUMN_COMPUTE_ENGINE_TYPE,"VARCHAR");
            map.put(COLUMN_LATENCY,"INTEGER");


            String tok[];

            for(int i=0; i< PARAMETERS.length; i++){
                tok = PARAMETERS[i].split(":");
                if(tok!=null && tok.length==2) {
                    map.put(tok[0], tok[1]);
                }
            }


            for(int i=0; i< ACCEPTED_PARAMETERS.length; i++){
                tok = ACCEPTED_PARAMETERS[i].split(":");
                if(tok!=null && tok.length==2) {
                    map.put(tok[0], tok[1]);
                }
            }

            for(int i=0; i< COUNTERS.length; i++){
                    tok = COUNTERS[i].split(":");
                    if(tok!=null && tok.length==2) {
                            map.put(tok[0], tok[1]);
                    }
            }



            return map;
        }


        public static List<String> getColumnNames(){
                List<String> columns = new ArrayList<String>();
                for(Map.Entry<String, String> e:  getColumnNameTypeMap().entrySet()){
                        columns.add(e.getKey());
                }

                return columns;
        }


        public static Map<String, BigInteger> getInitialCounterValuesMap(){
                Map<String, BigInteger> map = new HashMap<String, BigInteger>();

                String tok[];

                for(int i=0; i< COUNTERS.length; i++){
                        tok = COUNTERS[i].split(":");
                        if(tok!=null && tok.length==2) {
                                map.put(tok[0],  new BigInteger("0"));
                        }
                }

                return map;
        }



    public static Map<String, BigInteger> getInitialParameterValuesMap(){
        Map<String, BigInteger> map = new HashMap<String, BigInteger>();

        String tok[];

        for(int i=0; i< PARAMETERS.length; i++){
            tok = PARAMETERS[i].split(":");
            if(tok!=null && tok.length==2) {
                map.put(tok[0],  new BigInteger("0"));
            }
        }

        return map;
    }




    public static String getCountersTableSchema(){
        Map<String, String> nameTypeMap = getColumnNameTypeMap();
        StringBuilder schema = new StringBuilder();
        schema.append("CREATE TABLE IF NOT EXISTS " + COUNTERS_TABLE_NAME + " ( ");

        boolean isFirstAppend=true;
        Iterator<String> iterator = nameTypeMap.keySet().iterator();
        String primaryKey="";
        while (iterator.hasNext()){
            String name = iterator.next();
            if(name.equals(COLUMN_WORKLOAD_ID) || name.equals(COLUMN_JOB_ID) || name.equals(COLUMN_START_TIME)){
                if(primaryKey.equals(""))
                    primaryKey = name;
                else
                    primaryKey += "," + name;
            }

            if(isFirstAppend){
                schema.append(name).append(" ").append(nameTypeMap.get(name));
                isFirstAppend=false;
            }
            else
                schema.append(",").append(name).append(" ").append(nameTypeMap.get(name));
        }

        //schema.append(" CONSTRAINT pk PRIMARY KEY (").append(COLUMN_WORKLOAD_ID).append(",").append(COLUMN_JOB_ID).append(",").append(COLUMN_START_TIME).append("))");
        schema.append(" CONSTRAINT pk PRIMARY KEY (").append(primaryKey).append("))");

        return schema.toString();
    }







    public static String getWorkloadIdsTableSchema(){
                String schema = "CREATE TABLE IF NOT EXISTS " +
                        WORKLOAD_IDS_TABLE_NAME +
                        " ( WORKLOAD_ID INTEGER not null, DATE_TIME Date, HASH BIGINT ";

                schema += " CONSTRAINT pk PRIMARY KEY (WORKLOAD_ID) )";

                return schema;
        }

        public static void main(String[] args){


           //WorkloadCountersPhoenixDAO dao = new WorkloadCountersPhoenixDAO("104.130.29.25");
           //System.out.print(getCountersTableSchema());
        }

}
