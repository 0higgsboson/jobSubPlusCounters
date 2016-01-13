package com.sherpa.tunecore.joblauncher.mr;

import com.google.gson.Gson;
import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.dao.WorkloadCountersConfigurations;
import com.sherpa.core.utils.ConfigurationLoader;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.MRJobConf;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.MRJobCounters;
import com.sherpa.tunecore.joblauncher.SPI;
import com.sherpa.tunecore.joblauncher.Utils;
import com.sherpa.tunecore.metricsextractor.mapreduce.HistoricalJobCounters;
import com.sherpa.tunecore.metricsextractor.mapreduce.HistoricalTaskCounters;
import org.apache.commons.lang.StringEscapeUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigInteger;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by akhtar on 01/10/2015.
 */


public class MRCountersManager {
    private static final Logger log = LoggerFactory.getLogger(MRCountersManager.class);
    private MRJobCounters mrJobDetails = null;

    public void saveCounters(String jobId, long elapsedTime,  long startTime, long finishTime, String workloadId, Map<String, BigInteger> counters,
                             String configurations, String clusterId, String sherpaTuned, String tag, String origin){
        log.info("Saving Counters into Phoenix Table For Job ID: " + jobId);

        String jobHistoryServer = ConfigurationLoader.getJobHistoryUrl();

        WorkloadCountersManager workloadManager  = new WorkloadCountersManager();

        //String workloadId = workloadManager.getWorkloadHash(mapperClass);
        //String workloadId = workloadManager.getWorkloadHash(mapperClass+tag);


        // Remove following line for wall clock time
        elapsedTime = new HistoricalTaskCounters(jobHistoryServer).computeLatency(jobId);

        Map<String, BigInteger> jobCounters=new HashMap<String, BigInteger>();
        try{
            jobCounters = getJobCounters(jobId, jobHistoryServer);
        }catch (Exception e){
            jobCounters = new HashMap<String, BigInteger>();
        }


        String json = Utils.toString2(jobCounters);
        addCounters(jobCounters, counters);



        Map<String, String> configurationValues = new HashMap<String, String>();
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_JOB_ID, jobId);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_JOB_URL, SPI.getJobCountersUri(jobHistoryServer, jobId));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_START_TIME, Utils.convertTimeToString(startTime));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_END_TIME, Utils.convertTimeToString(finishTime));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_CONFIGURATIONS, configurations);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_COMPUTE_ENGINE_TYPE, WorkloadCountersConfigurations.COMPUTE_ENGINE_MR);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_COUNTERS, json);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_CLUSTER_ID, clusterId);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_SHERPA_TUNED, sherpaTuned);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_TAG, tag);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_ORIGIN, origin);

        addJobDetails(jobId, jobHistoryServer, configurationValues, counters);

        workloadManager.saveCounters(workloadId, (int) elapsedTime, counters, configurationValues);
        log.info("Done Saving Counters into Phoenix For Job ID: " + jobId);
        workloadManager.close();
    }


    public void saveHiveCounters(String jobId, long elapsedTime,  long startTime, long finishTime, String mapperClass, Map<String, BigInteger> counters,
                             String configurations, String clusterId, String sherpaTuned, String tag, String origin, boolean isAgg){
        log.info("Saving Counters into Phoenix Table For Job ID: " + jobId);

        String jobHistoryServer = ConfigurationLoader.getJobHistoryUrl();

        WorkloadCountersManager workloadManager  = new WorkloadCountersManager();

        //String workloadId = workloadManager.getWorkloadHash(mapperClass);

        String workloadId = workloadManager.getWorkloadHash(mapperClass+tag);


        Map<String, BigInteger> jobCounters=new HashMap<String, BigInteger>();
        try{
            jobCounters = getJobCounters(jobId, jobHistoryServer);
        }catch (Exception e){
            jobCounters = new HashMap<String, BigInteger>();
        }


        String json = Utils.toString2(jobCounters);
        addCounters(jobCounters, counters);



        Map<String, String> configurationValues = new HashMap<String, String>();
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_JOB_ID, jobId);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_JOB_URL, SPI.getJobCountersUri(jobHistoryServer, jobId));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_START_TIME, Utils.convertTimeToString(startTime));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_END_TIME, Utils.convertTimeToString(finishTime));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_CONFIGURATIONS, configurations);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_COMPUTE_ENGINE_TYPE, WorkloadCountersConfigurations.COMPUTE_ENGINE_MR);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_COUNTERS, json);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_CLUSTER_ID, clusterId);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_SHERPA_TUNED, sherpaTuned);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_TAG, tag);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_ORIGIN, origin);


        addJobDetails(jobId, jobHistoryServer, configurationValues, counters);

        workloadManager.saveCounters(workloadId, (int) elapsedTime, counters, configurationValues);
        log.info("Done Saving Counters into Phoenix For Job ID: " + jobId);
        workloadManager.close();
    }






    public Map<String, String> getJobMetaDataMap(String jobId, long startTime, long finishTime, String countersJson,
                             String configurations, String clusterId, String sherpaTuned, String tag, String origin, String computeEngineType){

        String jobHistoryServer = ConfigurationLoader.getJobHistoryUrl();

        //String countersJson = Utils.toString2(jobCounters);

        Map<String, String> configurationValues = new HashMap<String, String>();
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_JOB_ID, jobId);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_JOB_URL, SPI.getJobCountersUri(jobHistoryServer, jobId));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_START_TIME, Utils.convertTimeToString(startTime));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_END_TIME, Utils.convertTimeToString(finishTime));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_CONFIGURATIONS, configurations);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_COMPUTE_ENGINE_TYPE, computeEngineType);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_COUNTERS, countersJson);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_CLUSTER_ID, clusterId);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_SHERPA_TUNED, sherpaTuned);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_TAG, tag);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_ORIGIN, origin);

        return configurationValues;
    }








    public synchronized void addCounters(Map<String, BigInteger> jobCounters, Map<String, BigInteger> counters){
        addCounter(jobCounters, counters, "PHYSICAL_MEMORY_BYTES_MAP", "PHYSICAL_MEMORY_BYTES_MAP");
        addCounter(jobCounters, counters, "PHYSICAL_MEMORY_BYTES_REDUCE", "PHYSICAL_MEMORY_BYTES_REDUCE");

        addCounter(jobCounters, counters, "CPU_MILLISECONDS_MAP", "CPU_MILLISECONDS_MAP");
        addCounter(jobCounters, counters, "CPU_MILLISECONDS_REDUCE", "CPU_MILLISECONDS_REDUCE");

        addCounter(jobCounters, counters, "MB_MILLIS_MAPS_TOTAL", "MB_MILLIS_MAPS");
        addCounter(jobCounters, counters, "MB_MILLIS_REDUCES_TOTAL", "MB_MILLIS_REDUCES");

        addCounter(jobCounters, counters, "HDFS_BYTES_READ_TOTAL", "HDFS_BYTES_READ");
        addCounter(jobCounters, counters, "HDFS_BYTES_WRITTEN_TOTAL", "HDFS_BYTES_WRITTEN");

        addCounter(jobCounters, counters, "VCORES_MILLIS_MAPS_TOTAL", "VCORES_MILLIS_MAPS");
        addCounter(jobCounters, counters, "VCORES_MILLIS_REDUCES_TOTAL", "VCORES_MILLIS_REDUCES");

        addCounter(jobCounters, counters, "MILLIS_MAPS_TOTAL", "MILLIS_MAPS");
        addCounter(jobCounters, counters, "MILLIS_REDUCES_TOTAL", "MILLIS_REDUCES");

    }

    public synchronized void addCounter(Map<String, BigInteger> jobCounters, Map<String, BigInteger> counters, String jobCounterName, String counterName){
        if(jobCounters.containsKey(jobCounterName))
            counters.put(counterName, jobCounters.get(jobCounterName));
        else
            counters.put(counterName, new BigInteger("0"));
    }

    public synchronized Map<String, BigInteger> getJobCounters(String jobId, String historyServerUrl){
        Map<String, BigInteger> counterValues = null;
        try {
            System.out.println("Getting Job Counters");
            HistoricalJobCounters countersObj = new HistoricalJobCounters( historyServerUrl);
            counterValues = countersObj.getJobCounters(jobId);
            System.out.println("Done Getting Job Counters ...");
        } catch (Exception e) {
            e.printStackTrace();
        }

        return counterValues;
    }

    public synchronized Map<String, BigInteger> getJobCounters(String jobId){
        String jobHistoryServer = ConfigurationLoader.getJobHistoryUrl();
        Map<String, BigInteger> counterValues = null;
        try {
            System.out.println("Getting Job Counters");
            HistoricalJobCounters countersObj = new HistoricalJobCounters( jobHistoryServer);
            counterValues = countersObj.getJobCounters(jobId);
            System.out.println("Done Getting Job Counters ...");
        } catch (Exception e) {
            e.printStackTrace();
            counterValues = new HashMap<String, BigInteger>();
        }

        return counterValues;
    }




    public synchronized MRJobCounters addJobDetails(String jobId, String historyServerUrl, Map<String, String> configurations, Map<String, BigInteger> counters){
        MRJobCounters mrJobDetails = null;
        try {
            System.out.println("Getting Job Details");
            HistoricalJobCounters historicalJobObj = new HistoricalJobCounters( historyServerUrl);
            mrJobDetails = historicalJobObj.getJobDetails(jobId);

            configurations.put(WorkloadCountersConfigurations.COLUMN_USER, mrJobDetails.getJob().getUser());
            configurations.put(WorkloadCountersConfigurations.COLUMN_QUEUE, mrJobDetails.getJob().getQueue());

            MRJobConf conf = historicalJobObj.getJobConf(jobId);
            counters.put("accepted_mapreduce_job_maps", new BigInteger(conf.getPropertyValue("mapreduce.job.maps")));
            counters.put("accepted_mapreduce_job_reduces", new BigInteger(conf.getPropertyValue("mapreduce.job.reduces")));
            counters.put("accepted_mapreduce_map_memory_mb", new BigInteger(conf.getPropertyValue("mapreduce.map.memory.mb")));
            counters.put("accepted_mapreduce_reduce_memory_mb", new BigInteger(conf.getPropertyValue("mapreduce.reduce.memory.mb")));
            counters.put("accepted_mapreduce_map_cpu_vcores", new BigInteger(conf.getPropertyValue("mapreduce.map.cpu.vcores")));
            counters.put("accepted_mapreduce_reduce_cpu_vcores", new BigInteger(conf.getPropertyValue("mapreduce.reduce.cpu.vcores")));

            System.out.println("Done Getting Job Details ...");

        } catch (Exception e) {
            e.printStackTrace();
        }
        return mrJobDetails;
    }


    public synchronized MRJobCounters addHiveJobDetails(String jobId, String historyServerUrl, Map<String, String> configurations, Map<String, BigInteger> counters, boolean isAgg){
        MRJobCounters mrJobDts = null;
        try {
            System.out.println("Getting Job Details");
            if(isAgg){
                if(this.mrJobDetails!=null){
                    configurations.put(WorkloadCountersConfigurations.COLUMN_USER, this.mrJobDetails.getJob().getUser());
                    configurations.put(WorkloadCountersConfigurations.COLUMN_QUEUE, this.mrJobDetails.getJob().getQueue());
                }
            }
            else {
                HistoricalJobCounters historicalJobObj = new HistoricalJobCounters(historyServerUrl);
                mrJobDts = historicalJobObj.getJobDetails(jobId);

                configurations.put(WorkloadCountersConfigurations.COLUMN_USER, mrJobDts.getJob().getUser());
                configurations.put(WorkloadCountersConfigurations.COLUMN_QUEUE, mrJobDts.getJob().getQueue());

                MRJobConf conf = historicalJobObj.getJobConf(jobId);
                counters.put("accepted_mapreduce_job_maps", new BigInteger(conf.getPropertyValue("mapreduce.job.maps")));
                counters.put("accepted_mapreduce_job_reduces", new BigInteger(conf.getPropertyValue("mapreduce.job.reduces")));
                counters.put("accepted_mapreduce_map_memory_mb", new BigInteger(conf.getPropertyValue("mapreduce.map.memory.mb")));
                counters.put("accepted_mapreduce_reduce_memory_mb", new BigInteger(conf.getPropertyValue("mapreduce.reduce.memory.mb")));
                counters.put("accepted_mapreduce_map_cpu_vcores", new BigInteger(conf.getPropertyValue("mapreduce.map.cpu.vcores")));
                counters.put("accepted_mapreduce_reduce_cpu_vcores", new BigInteger(conf.getPropertyValue("mapreduce.reduce.cpu.vcores")));
            }
            System.out.println("Done Getting Job Details ...");

        } catch (Exception e) {
            e.printStackTrace();
        }

        this.mrJobDetails = mrJobDts;
        return mrJobDts;
    }







    public synchronized BigInteger addReservedMemory(String jobId, String historyServerUrl, Map<String, BigInteger> counters){
        BigInteger reservedMemory = new BigInteger("0");
        BigInteger mbFactor = new BigInteger("1024");
        try {
            System.out.println("Computing Reserved Memory");
            HistoricalTaskCounters taskCounters = new HistoricalTaskCounters(historyServerUrl);
            BigInteger mapMem = counters.get("accepted_mapreduce_map_memory_mb");
            BigInteger redMem = counters.get("accepted_mapreduce_reduce_memory_mb");
            reservedMemory = taskCounters.computeReservedMemory(jobId, mapMem, redMem);

            counters.put("RESERVED_MEMORY", reservedMemory);

            System.out.println("Done Computing Reserved Memory: " + reservedMemory);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return reservedMemory;
    }



    public synchronized BigInteger addReservedCpu(String jobId, String historyServerUrl, Map<String, BigInteger> counters){
        BigInteger reservedCpu = new BigInteger("0");
        try {
            System.out.println("Computing Reserved CPU");
            HistoricalTaskCounters taskCounters = new HistoricalTaskCounters( historyServerUrl);
            BigInteger mapCores = counters.get("accepted_mapreduce_map_cpu_vcores");
            BigInteger redCores = counters.get("accepted_mapreduce_reduce_cpu_vcores");
            reservedCpu = taskCounters.computeReservedCpu(jobId, mapCores, redCores);

            counters.put("RESERVED_CPU", reservedCpu);

            System.out.println("Done Computing Reserved CPU: " + reservedCpu);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return reservedCpu;
    }






}
