package com.sherpa.tunecore.joblauncher.mr;

import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.dao.WorkloadCountersConfigurations;
import com.sherpa.core.utils.ConfigurationLoader;
import com.sherpa.tunecore.metricsextractor.mapreduce.HistoricalJobCounters;

import java.math.BigInteger;
import java.util.Date;
import java.util.Map;

/**
 * Created by akhtar on 01/10/2015.
 */


public class MRCountersManager {

    public void saveCounters(String jobId, String params, long elapsedTime, String mapperClass){

        String appServer = ConfigurationLoader.getApplicationServerUrl();
        String jobHistoryServer = ConfigurationLoader.getJobHistoryUrl();

        Date date = new Date();
        WorkloadCountersManager workloadManager  = new WorkloadCountersManager();

        int workloadId = workloadManager.getWorkloadIDFromFileContents(mapperClass);
        System.out.println("Workload ID: " + workloadId);
        if(workloadId<0){
            System.out.println("Error: could not generate worklod id ...");
            workloadManager.close();
            return;
        }


        Map<String, BigInteger> jobCounters = getJobCounters(jobId, jobHistoryServer);


        System.out.println("Saving Counters into Phoenix Table For Job ID: " + jobId);
        workloadManager.saveCounters(workloadId, date, (int) elapsedTime, jobId, WorkloadCountersConfigurations.JOB_TYPE_MR, jobCounters, "", params);
        System.out.println("Done Saving Counters into Phoenix For Job ID: " + jobId);
        workloadManager.close();


    }


    private Map<String, BigInteger> getJobCounters(String jobId, String historyServerUrl){

        Map<String, BigInteger> counterValues = null;
        try {
            System.out.println("Getting Job Counters");
            HistoricalJobCounters countersObj = new HistoricalJobCounters( historyServerUrl);
            countersObj.getJobCounters(jobId);
            counterValues = countersObj.getJobCounters(jobId);
            System.out.println("Done Getting Job Counters ...");

        } catch (Exception e) {
            e.printStackTrace();
        }

        return counterValues;
    }







}
