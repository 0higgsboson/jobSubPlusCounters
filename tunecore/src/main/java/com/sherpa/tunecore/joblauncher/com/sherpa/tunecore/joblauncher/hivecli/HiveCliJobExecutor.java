package com.sherpa.tunecore.joblauncher.com.sherpa.tunecore.joblauncher.hivecli;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.dao.WorkloadCountersConfigurations;
import com.sherpa.tunecore.entitydefinitions.job.execution.Application;
import com.sherpa.tunecore.joblauncher.SPI;
import com.sherpa.tunecore.joblauncher.Utils;
import com.sherpa.tunecore.joblauncher.mr.MRCountersManager;
import com.sherpa.tunecore.metricsextractor.mapreduce.HistoricalJobCounters;
import com.sherpa.tunecore.metricsextractor.mapreduce.HistoricalTaskCounters;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.math.BigInteger;
import java.util.*;

/**
 * Created by akhtar on 10/08/2015.
 */



public class HiveCliJobExecutor extends Thread{
    private static final Logger log = LoggerFactory.getLogger(HiveCliJobExecutor.class);
    // resource manager url to track application status
    private String resourceManagerUrl;
    // job history server url to pull counters data
    private String historyServerUrl;
    // interval after which job/application status is checked
    private int pollInterval;
    // keeps application's run time status
    private Application app;
    // workload ID
    private int workloadId=-1;


    private MRCountersManager mrCountersManager;
    private HiveCliJobIdExtractor hiveJobIdExtractor;
    // Hive Job Extractor Thread adds jobs id in that queue
    private Queue<String> jobQueue = new LinkedList<String>();
    // // Hive Job Extractor Thread sets it to true once all job ids are added in the queue
    private boolean isJobsFinished=false;

    private long totalElapsedTime = 0;
    private Map<String, BigInteger > jobCountersMap = WorkloadCountersConfigurations.getInitialCounterValuesMap();

    private String aggregateJobId = "";

    WorkloadCountersManager workloadManager;
    Date date;

    private String fileLines;
    private int totalJobs=-1;

    // these are set from hive client using setter functions
    private Map<String, BigInteger> params = null;
    private String configurations= null;
    private String clusterID= "sherpa-default";
    private String sherpaTuned= "No";


    public HiveCliJobExecutor(String fileLines, String rmUrl, String historyServer, int pollInterval){
        this.fileLines = fileLines;
        this.resourceManagerUrl = rmUrl;
        this.historyServerUrl     = historyServer;
        this.pollInterval = pollInterval;

        date = new Date();
        workloadManager = new WorkloadCountersManager();
        mrCountersManager = new MRCountersManager();
    }



    /**
     *  Implements the controlling part of the job execution, tracking and saving
     */
    public void run(){

        log.info("Finding Workload ID for: " + fileLines);
        System.out.println("Finding Workload ID for: " + fileLines);

        workloadId = workloadManager.getWorkloadIDFromFileContents(fileLines);

        log.info("Workload ID: "+ workloadId);
        System.out.println("Workload ID: " + workloadId);

        if(workloadId<0){
            log.error("Error: could not generate worklod id ...");
            workloadManager.close();
            return;
        }


        int jobsProcessed = 0;


        // process until job id extractor is terminated and job queue is empty
        while(  jobsProcessed!=totalJobs ) {
            System.out.println("**** Sherpa Log: Queue Size=" + jobQueue.size() + "\t Jobs Processed=" +isJobsFinished + "\t Total Jobs:" + totalJobs );

            int waitCount = 0;
            while(jobQueue.isEmpty()){
                try {
                    log.info("Waiting For More Jobs To Come ...");
                    System.out.println("Waiting For More Jobs To Come ...");
                    waitCount +=1000;
                    Thread.sleep(1000);
                }catch (InterruptedException e){
                    log.error(e.getMessage());
                }

                if(waitCount >= (1000 * 60) ){
                    log.info("Waited for a minute, no new job came,  ...");
                    System.out.println("Waited for a minute, no new job came,  ...");
                    break;
                }
            }


            if(jobQueue.isEmpty()){
                log.info("No new job to process, shutting down ...");
                System.out.println("No new job to process, shutting down ...");
                break;
            }


            String jobId = jobQueue.remove();
            if (jobId == null || jobId.isEmpty()) {
                log.info("Error: Job ID Empty");
                System.out.println("Error: Job ID Empty");
                continue;
            }

            log.info("Processing Job: " + jobId);
            System.out.println("Processing Job: " + jobId);

            // waits for job/application to complete
            log.info("Waiting for application to complete");
            System.out.println("Waiting for application to complete");
            boolean appStatus = waitForCompletion(jobId);

            // Saves counters data only when job is successfull
            if (appStatus) {
                long elapsedTime = getElapsedTime();
                log.info("Elapsed Time: " + elapsedTime);
                System.out.println("Elapsed Time: " + elapsedTime);

                log.info("Adding Elapsed Time:  " +  totalElapsedTime + " + " + elapsedTime);
                totalElapsedTime += elapsedTime;

                System.out.println("Running Elapsed Time:  " + totalElapsedTime);
                log.info("Running Elapsed Time:  " + totalElapsedTime);

                // Saves task counters
                log.info("Getting Task Counters ...");
                System.out.println("Getting Task Counters ...");

                //Map<String, BigInteger> jobCounters = getTaskCounters(jobId);
                Map<String, BigInteger> jobCounters = getJobCounters(jobId);
                if(jobCounters!=null) {
                    saveWorkloadCounters(jobId, elapsedTime, jobCounters, false);
                    addToCounters(jobCounters);
                }

                if(aggregateJobId.isEmpty())
                    aggregateJobId=jobId;
                else
                    aggregateJobId += ":" + jobId;


                jobsProcessed++;

                log.info("Total Jobs Processed: " + jobsProcessed);
                System.out.println("Total Jobs Processed: " + jobsProcessed + " out of " + totalJobs);


            }



        }// main while loop

        if(totalJobs > 1) {
            log.info("Saving Aggregated Counters For " + jobsProcessed + " Jobs");
            System.out.println("Saving Aggregated Counters For " + jobsProcessed + " Jobs");


            saveWorkloadCounters(aggregateJobId, totalElapsedTime, jobCountersMap, true);
            workloadManager.close();
            log.info("Finished All Tasks ... " + jobsProcessed);
            System.out.println("Finished All Tasks ... " + jobsProcessed);
        }

    }


    private Map<String, BigInteger> getJobCounters(String jobId){

        Map<String, BigInteger> counterValues = null;
        try {
            log.info("Getting Job Counters");
            HistoricalJobCounters countersObj = new HistoricalJobCounters( historyServerUrl);
            //countersObj.getJobCounters(jobId);
            counterValues = countersObj.getJobCounters(jobId);
            log.info("Done Getting Job Counters ...");

        } catch (Exception e) {
            e.printStackTrace();
        }

        return counterValues;
    }




    private Map<String, BigInteger> getTaskCounters(String jobId){
        Map<String, BigInteger> counterValues = null;
        try {
            HistoricalTaskCounters historicalTaskCounters = new HistoricalTaskCounters( historyServerUrl);
            historicalTaskCounters.getJobCounters(jobId);
            counterValues = historicalTaskCounters.getCounterValues();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return counterValues;
    }




    private void saveWorkloadCounters(String jobId, long elapsedTime, Map<String, BigInteger> jobCounters, boolean isAggregate){
        log.info("Saving Counters into Phoenix Table For Job ID: " + jobId);

        String json = Utils.toString2(jobCounters);
        Map<String, String> configurationValues = new HashMap<String, String>();
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_JOB_ID, jobId);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_JOB_URL, SPI.getJobCountersUri(historyServerUrl, jobId));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_START_TIME, app.getApp().getStartTimeAsString());
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_END_TIME, app.getApp().getFinishTimeAsString());
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_CONFIGURATIONS, configurations);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_COMPUTE_ENGINE_TYPE, WorkloadCountersConfigurations.COMPUTE_ENGINE_HIVE);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_COUNTERS, json);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_CLUSTER_ID, clusterID);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_SHERPA_TUNED, sherpaTuned);
        mrCountersManager.addJobDetails(jobId, historyServerUrl, configurationValues);


        mrCountersManager.addCounters(jobCounters, params);



        if(!isAggregate) {
            BigInteger rm = mrCountersManager.getReservedMemory(jobId, historyServerUrl, params);
            params.put("RESERVED_MEMORY", rm);
            jobCounters.put("RESERVED_MEMORY", rm);
        }
        System.out.println("\n\nParameters: " + params);

        workloadManager.saveCounters(workloadId, (int) elapsedTime, params, configurationValues);
        log.info("Done Saving Counters into Phoenix For Job ID: " + jobId);
        workloadManager.close();
    }


    public void addToCounters(Map<String, BigInteger> jobCounters){
        Iterator<String> counters = jobCountersMap.keySet().iterator();
        while(counters.hasNext()){
            String counterName = counters.next();
            try {
                if(jobCounters.containsKey(counterName)){
                    BigInteger counterSumValue = jobCounters.get(counterName).add(jobCountersMap.get(counterName));
                    jobCountersMap.put(counterName, counterSumValue);
                }

            }catch (Exception e){
                e.printStackTrace();
            }
        }
    }





    private Process launchCommand(String command){
        Process process = null;
        try {
          /*  ProcessBuilder hiveProcessBuilder = new ProcessBuilder("hive", "-e",
                    command);

            return hiveProcessBuilder.start();
*/
             //process = Runtime.getRuntime().exec(new String[]{"hive", "-e", command});
            process = Runtime.getRuntime().exec(command);
        } catch (IOException e) {
            e.printStackTrace();
            log.error(e.getMessage());
        }

        return process;
    }


    private boolean waitForCompletion(String jobId){
        // YARN uses the word application instead of job, so replacing job with application
        String applicationId = jobId.replace("job", "application");
        log.info("Application ID: " + applicationId);

        RestTemplate restTemplate = new RestTemplate();

        String url = resourceManagerUrl;
        if(!resourceManagerUrl.endsWith("/"))
            url += "/";

        url += applicationId;

        app = restTemplate.getForObject(url, Application.class);


        log.info("Application Status: " + app);

        // States taken from the following URL
        // https://hadoop.apache.org/docs/r2.6.0/hadoop-yarn/hadoop-yarn-site/ResourceManagerRest.html#Cluster_Application_API
        // All possible states: NEW, NEW_SAVING, SUBMITTED, ACCEPTED, RUNNING, FINISHED, FAILED, KILLED
        while(  !app.getApp().getState().equalsIgnoreCase("FINISHED") &&
                !app.getApp().getState().equalsIgnoreCase("FAILED") &&
                !app.getApp().getState().equalsIgnoreCase("KILLED")

                ){
            log.info("Application Status: " + app.getApp().getState());
            try {
                log.info("Waiting for " + pollInterval + " milli sec");
                //System.out.println("Waiting for " + pollInterval + " milli sec for job " + jobId + " to complete");
                Thread.sleep(pollInterval);
            } catch (InterruptedException e) {
                e.printStackTrace();
                return false;
            }
            app = restTemplate.getForObject(url, Application.class);

        }
        return true;
    }



    public long getElapsedTime(){
        long elapsedTime=0;

        if(app!=null && app.getApp()!=null){
            try {
                elapsedTime = Long.parseLong(app.getApp().getElapsedTime());
            }catch (NumberFormatException e){
                e.printStackTrace();
            }
        }

        return elapsedTime;
    }




    public void setWorkloadId(int workloadId) {
        this.workloadId = workloadId;
    }


    public Queue<String> getJobQueue() {
        return jobQueue;
    }

    public boolean isJobsFinished() {
        return isJobsFinished;
    }


    public void setJobQueue(Queue<String> jobQueue) {
        this.jobQueue = jobQueue;
    }

    public void setIsJobsFinished(boolean isJobsFinished) {
        this.isJobsFinished = isJobsFinished;
    }

    public int getTotalJobs() {
        return totalJobs;
    }

    public void setTotalJobs(int totalJobs) {
        this.totalJobs = totalJobs;
    }


    public String getConfigurations() {
        return configurations;
    }

    public void setConfigurations(String configurations) {
        this.configurations = configurations;
    }

    public Map<String, BigInteger> getParams() {
        return params;
    }

    public void setParams(Map<String, BigInteger> params) {
        this.params = params;
    }

    public String getClusterID() {
        return clusterID;
    }

    public void setClusterID(String clusterID) {
        this.clusterID = clusterID;
    }

    public String getSherpaTuned() {
        return sherpaTuned;
    }

    public void setSherpaTuned(String sherpaTuned) {
        this.sherpaTuned = sherpaTuned;
    }
}
