package com.sherpa.tunecore.joblauncher.mr;

import com.google.gson.Gson;
import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.dao.WorkloadCountersConfigurations;
import com.sherpa.core.utils.ConfigurationLoader;
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


    public void saveCounters(String jobId, long elapsedTime,  long startTime, long finishTime, String mapperClass, Map<String, BigInteger> params, String configurations){
        log.info("Saving Counters into Phoenix Table For Job ID: " + jobId);

        configurations = StringEscapeUtils.escapeSql(configurations);
        configurations = configurations.replaceAll("'", "\\'");

        String appServer = ConfigurationLoader.getApplicationServerUrl();
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


        //String json = new Gson().toJson(jobCounters);
        String json = Utils.toString2(jobCounters);
        System.out.println("\n\nCounters Json: " + json);
        Map<String, String> configurationValues = new HashMap<String, String>();
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_JOB_ID, jobId);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_JOB_URL, SPI.getJobCountersUri(jobHistoryServer, jobId));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_START_TIME, Utils.convertTimeToString(startTime));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_END_TIME, Utils.convertTimeToString(finishTime));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_CONFIGURATIONS, configurations);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_COMPUTE_ENGINE_TYPE, WorkloadCountersConfigurations.COMPUTE_ENGINE_MR);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_COUNTERS, json);

        if(jobCounters.containsKey("PHYSICAL_MEMORY_BYTES_MAP"))
            params.put("PHYSICAL_MEMORY_BYTES_MAP", jobCounters.get("PHYSICAL_MEMORY_BYTES_MAP"));
        else
            params.put("PHYSICAL_MEMORY_BYTES_MAP", new BigInteger("0"));

        if(jobCounters.containsKey("PHYSICAL_MEMORY_BYTES_REDUCE"))
            params.put("PHYSICAL_MEMORY_BYTES_REDUCE", jobCounters.get("PHYSICAL_MEMORY_BYTES_REDUCE"));
        else
            params.put("PHYSICAL_MEMORY_BYTES_REDUCE", new BigInteger("0"));

        if(jobCounters.containsKey("CPU_MILLISECONDS_MAP"))
            params.put("CPU_MILLISECONDS_MAP", jobCounters.get("CPU_MILLISECONDS_MAP"));
        else
            params.put("CPU_MILLISECONDS_MAP", new BigInteger("0"));


        if(jobCounters.containsKey("CPU_MILLISECONDS_REDUCE"))
            params.put("CPU_MILLISECONDS_REDUCE", jobCounters.get("CPU_MILLISECONDS_REDUCE"));
        else
            params.put("CPU_MILLISECONDS_REDUCE", new BigInteger("0"));


        params.put("reserved_memory", getReservedMemory(jobId, jobHistoryServer, jobCounters));

        workloadManager.saveCounters(workloadId, (int) elapsedTime, params, configurationValues);
        log.info("Done Saving Counters into Phoenix For Job ID: " + jobId);
        workloadManager.close();
    }




    private Map<String, BigInteger> getJobCounters(String jobId, String historyServerUrl){

        Map<String, BigInteger> counterValues = null;
        try {
            System.out.println("Getting Job Counters");
            HistoricalJobCounters countersObj = new HistoricalJobCounters( historyServerUrl);
            //countersObj.getJobCounters(jobId);
            counterValues = countersObj.getJobCounters(jobId);
            System.out.println("Done Getting Job Counters ...");

        } catch (Exception e) {
            e.printStackTrace();
        }

        return counterValues;
    }




    public static synchronized BigInteger getReservedMemory(String jobId, String historyServerUrl, Map<String, BigInteger> counters){
        BigInteger reservedMemory = new BigInteger("0");
        BigInteger mbConvertor = new BigInteger("1048576");
        try {
            System.out.println("Computing Reserved Memory");
            HistoricalTaskCounters taskCounters = new HistoricalTaskCounters( historyServerUrl);
            BigInteger mapMem = counters.get("PHYSICAL_MEMORY_BYTES_MAP").divide(mbConvertor);
            BigInteger redMem = counters.get("PHYSICAL_MEMORY_BYTES_REDUCE").divide(mbConvertor);
            reservedMemory = taskCounters.computeReservedMemory(jobId, mapMem, redMem);
            System.out.println("Computed Reserved Memory: " + reservedMemory);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return reservedMemory;
    }






}
