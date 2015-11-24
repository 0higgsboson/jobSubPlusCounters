package com.sherpa.tunecore.joblauncher.mr;

import com.google.gson.Gson;
import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.dao.WorkloadCountersConfigurations;
import com.sherpa.core.utils.ConfigurationLoader;
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


    public void saveCounters(String jobId, long elapsedTime,  long startTime, long finishTime, String mapperClass, Map<String, BigInteger> counters, String configurations, String clusterId, String sherpaTuned){
        log.info("Saving Counters into Phoenix Table For Job ID: " + jobId);

        configurations = escapeString(configurations);

        String jobHistoryServer = ConfigurationLoader.getJobHistoryUrl();

        WorkloadCountersManager workloadManager  = new WorkloadCountersManager();

        int workloadId = workloadManager.getWorkloadIDFromFileContents(mapperClass);
        System.out.println("Workload ID: " + workloadId);
        if(workloadId<0){
            System.out.println("Error: could not generate worklod id ...");
            workloadManager.close();
            return;
        }


        Map<String, BigInteger> jobCounters = getJobCounters(jobId, jobHistoryServer);
        String json = Utils.toString2(jobCounters);
        addCounters(jobCounters, counters);
        counters.put("RESERVED_MEMORY", getReservedMemory(jobId, jobHistoryServer, counters));


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

        addJobDetails(jobId, jobHistoryServer, configurationValues);


        workloadManager.saveCounters(workloadId, (int) elapsedTime, counters, configurationValues);
        log.info("Done Saving Counters into Phoenix For Job ID: " + jobId);
        workloadManager.close();
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




    public synchronized MRJobCounters addJobDetails(String jobId, String historyServerUrl, Map<String, String> configurations){
        MRJobCounters mrJobDetails = null;
        try {
            System.out.println("Getting Job Details");
            HistoricalJobCounters historicalJobObj = new HistoricalJobCounters( historyServerUrl);
            mrJobDetails = historicalJobObj.getJobDetails(jobId);

            configurations.put(WorkloadCountersConfigurations.COLUMN_USER, mrJobDetails.getJob().getUser());
            configurations.put(WorkloadCountersConfigurations.COLUMN_QUEUE, mrJobDetails.getJob().getQueue());

            System.out.println("Done Getting Job Details ...");

        } catch (Exception e) {
            e.printStackTrace();
        }
        return mrJobDetails;
    }



    public synchronized BigInteger getReservedMemory(String jobId, String historyServerUrl, Map<String, BigInteger> counters){
        BigInteger reservedMemory = new BigInteger("0");
        BigInteger mbConvertor = new BigInteger("1048576");
        try {
            System.out.println("Computing Reserved Memory");
            HistoricalTaskCounters taskCounters = new HistoricalTaskCounters( historyServerUrl);
            BigInteger mapMem = counters.get("MB_MILLIS_MAPS").divide(mbConvertor);
            BigInteger redMem = counters.get("MB_MILLIS_REDUCES").divide(mbConvertor);
            reservedMemory = taskCounters.computeReservedMemory(jobId, mapMem, redMem);
            System.out.println("Done Computing Reserved Memory: " + reservedMemory);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return reservedMemory;
    }



    public synchronized String escapeString(String str){
        String res = StringEscapeUtils.escapeSql(str);
        return res.replaceAll("'", "\\'");
    }



}
