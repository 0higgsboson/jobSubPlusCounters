package com.sherpa.tunecore.joblauncher.com.sherpa.tunecore.joblauncher.hivecli;

import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.dao.WorkloadCountersConfigurations;
import com.sherpa.core.utils.ConfigurationLoader;
import com.sherpa.tunecore.entitydefinitions.job.execution.Application;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.AllTasks;
import com.sherpa.tunecore.joblauncher.SPI;
import com.sherpa.tunecore.joblauncher.Utils;
import com.sherpa.tunecore.joblauncher.mr.MRCountersManager;
import com.sherpa.tunecore.metricsextractor.mapreduce.HistoricalJobCounters;
import com.sherpa.tunecore.metricsextractor.mapreduce.HistoricalTaskCounters;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.client.RestTemplate;

import java.awt.*;
import java.io.IOException;
import java.math.BigInteger;
import java.util.*;
import java.util.List;

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
    private String workloadId="";
    private String startTime, finishTime;


    private MRCountersManager mrCountersManager;
    private HiveCliJobIdExtractor hiveJobIdExtractor;
    // Hive Job Extractor Thread adds jobs id in that queue
    private Queue<String> jobQueue = new LinkedList<String>();
    // // Hive Job Extractor Thread sets it to true once all job ids are added in the queue
    private boolean isJobsFinished=false;

    private long totalElapsedTime = 0, totalLatency=0;
    private Map<String, BigInteger > aggregatedCounters = WorkloadCountersConfigurations.getInitialCounterValuesMap();

    private Map<String, BigInteger > allCounters = new HashMap<String, BigInteger>();

    private String aggregateJobId = "";
    private boolean isException=false;

    WorkloadCountersManager workloadManager;
    Date date;


    private int totalJobs=-1;
    private int jobsProcessed = 0;

    // these are set from hive client using setter functions
    private Map<String, BigInteger> params = null;
    private String configurations= null;
    private String clusterID= "sherpa-default";
    private String sherpaTuned= "No";
    private String tag="NA", origin="NA";

    // keeps task counters
    private List<AllTasks> tasks = new  ArrayList<AllTasks>();


    public HiveCliJobExecutor(String wid, String rmUrl, String historyServer, int pollInterval){
        this.workloadId = wid;
        this.resourceManagerUrl = rmUrl;
        this.historyServerUrl     = historyServer;
        this.pollInterval = pollInterval;

        date = new Date();
        workloadManager = new WorkloadCountersManager();
        mrCountersManager = new MRCountersManager();
    }


    public HiveCliJobExecutor(String wid){
        this.workloadId = wid;
        this.resourceManagerUrl = ConfigurationLoader.getApplicationServerUrl();
        this.historyServerUrl     = ConfigurationLoader.getJobHistoryUrl();
        this.pollInterval = ConfigurationLoader.getPollInterval();

        date = new Date();
        workloadManager = new WorkloadCountersManager();
        mrCountersManager = new MRCountersManager();
    }


    private void waitForJob(){
        int waitCount = 0;
        while(jobQueue.isEmpty() && !isException){
            try {
                System.out.println("Waiting For More Jobs To Come ...");
                waitCount +=1000;
                Thread.sleep(1000);
            }catch (InterruptedException e){
                log.error(e.getMessage());
            }

            if(waitCount >= (1000 * 60) ){
                System.out.println("\n\n\n ************************* Error: Waited for one minute, no new job to process  ...");
                break;
            }
        }
    }


    /**
     *  Implements the controlling part of the job execution, tracking and saving
     */
    public void run(){
        System.out.println("Workload ID: " + workloadId);

        HistoricalTaskCounters historicalTaskCounters = new HistoricalTaskCounters(historyServerUrl);

        // process until job id extractor is terminated and job queue is empty
        while(  jobsProcessed!=totalJobs ) {
            System.out.println("Queue Size=" + jobQueue.size() + "\t Jobs Processed=" +jobsProcessed + "\t Total Jobs:" + totalJobs );

            // waits for new job to start
            waitForJob();

            if(jobQueue.isEmpty()){
                System.out.println("No new job to process, shutting down ...");
                break;
            }


            String jobId = jobQueue.remove();
            if (jobId == null || jobId.isEmpty()) {
                System.out.println("Error: Job ID Empty");
                continue;
            }


            boolean appStatus = waitForCompletion(jobId);

            if (appStatus) {
                long elapsedTime = getElapsedTime();
                totalElapsedTime += elapsedTime;
                System.out.println("Elapsed Time: " + elapsedTime + "\tTotal Elapsed Time:  " + totalElapsedTime);

                System.out.println("Getting Job Counters ...");
                Map<String, BigInteger> jobCounters = getJobCounters(jobId);

                if(jobCounters!=null) {
                    long latency = historicalTaskCounters.computeLatency(jobId);

                    System.out.println("Getting Tasks Counters ...");
                    AllTasks allTasks = historicalTaskCounters.getTasksCounters(jobId);
                    if(allTasks!=null)
                        tasks.add(allTasks);

                    // all counters aggregation for learning module
                    aggregateAllCounters(jobCounters);


                    //saveWorkloadCounters(jobId, elapsedTime, latency, jobCounters, app.getApp().getStartTimeAsString(), app.getApp().getFinishTimeAsString(), false);

                    if(jobsProcessed==0)
                        startTime = app.getApp().getStartTimeAsString();

                    finishTime = app.getApp().getFinishTimeAsString();

                    totalLatency += latency;
                }

                if(aggregateJobId.isEmpty())
                    aggregateJobId="agg_"+jobId;
                else
                    aggregateJobId += "," + jobId;


                jobsProcessed++;

                System.out.println("Total Jobs Processed: " + jobsProcessed + " out of " + totalJobs);


            }



        }// main while loop


        allCounters.put("Execution_Time", BigInteger.valueOf(totalElapsedTime));
        allCounters.put("Latency", BigInteger.valueOf(totalLatency));
        System.out.println("Execution Time: " + totalElapsedTime + "\t Latency: " + totalLatency);
        System.out.println("Done processing " + jobsProcessed + " Jobs");


    }


    private Map<String, BigInteger> getJobCounters(String jobId){

        Map<String, BigInteger> counterValues = null;
        try {
            log.info("Getting Job Counters");
            HistoricalJobCounters countersObj = new HistoricalJobCounters( historyServerUrl);
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



    private void saveWorkloadCounters(String jobId, long elapsedTime, long latency, Map<String, BigInteger> jobCounters, String startTime, String finishTime, boolean isAgg){
        log.info("Saving Counters into Phoenix Table For Job ID: " + jobId);

        String json = Utils.toString2(jobCounters);
        Map<String, String> configurationValues = new HashMap<String, String>();
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_JOB_ID, jobId);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_JOB_URL, SPI.getJobCountersUri(historyServerUrl, jobId));
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_START_TIME, startTime );
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_END_TIME, finishTime );
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_CONFIGURATIONS, configurations);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_COMPUTE_ENGINE_TYPE, WorkloadCountersConfigurations.COMPUTE_ENGINE_HIVE);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_COUNTERS, json);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_CLUSTER_ID, clusterID);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_SHERPA_TUNED, sherpaTuned);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_TAG, tag);
        configurationValues.put(WorkloadCountersConfigurations.COLUMN_ORIGIN, origin);

        mrCountersManager.addHiveJobDetails(jobId, historyServerUrl, configurationValues, params, isAgg);

        if(isAgg)
            copy(jobCounters, params);
        else {
            // add required counters from src map to dest map
            mrCountersManager.addCounters(jobCounters, params);
        }

        if(isAgg) {
            System.out.println("\n\n Saving Parameters & Counters: " + params);
            System.out.println("\n Meta Data: " + configurationValues);

            allCounters.put("Execution_Time", BigInteger.valueOf(elapsedTime));
            allCounters.put("Latency", BigInteger.valueOf(latency));
            //workloadManager.saveCounters(workloadId, elapsedTime, latency, params, configurationValues);
            //log.info("Done Saving Counters into Phoenix For Job ID: " + jobId);
        }
        else {
            // Aggregate counters values, for hbase
            addToCounters(params);
        }
    }


    public void copy(Map<String, BigInteger> src, Map<String, BigInteger> dst){
        Iterator<String> iterator = src.keySet().iterator();
        while(iterator.hasNext()){
            String counterName = iterator.next();
            try {
                if(dst.containsKey(counterName)){
                    BigInteger value = src.get(counterName);
                    dst.put(counterName, value);
                }
            }catch (Exception e){
                e.printStackTrace();
            }
        }
    }


    public void aggregateAllCounters(Map<String, BigInteger> jobCounters) {
        Iterator<String> counters = jobCounters.keySet().iterator();
        while (counters.hasNext()) {
            String counterName = counters.next();
            if(allCounters.containsKey(counterName)){
                BigInteger counterSumValue = jobCounters.get(counterName).add(allCounters.get(counterName));
                allCounters.put(counterName, counterSumValue);
            }
            else{
                BigInteger counterSumValue = jobCounters.get(counterName);
                allCounters.put(counterName, counterSumValue);
            }
        }
    }


    public void addToCounters(Map<String, BigInteger> jobCounters){
        System.out.println("\nAgg Counters: " + aggregatedCounters);
        System.out.println("\nCounters: " + jobCounters);



        Iterator<String> counters = aggregatedCounters.keySet().iterator();
        while(counters.hasNext()){
            String counterName = counters.next();
            try {
                if(counterName.equalsIgnoreCase("HDFS_BYTES_WRITTEN") || counterName.equalsIgnoreCase("HDFS_BYTES_READ")){
                    // for these two counters, keeps the values of only first job run
                    BigInteger value = aggregatedCounters.get(counterName);
                    if(value.longValue()==0){
                        BigInteger counterSumValue = jobCounters.get(counterName);
                        aggregatedCounters.put(counterName, counterSumValue);
                    }
                }
                else if(jobCounters.containsKey(counterName)){
                    BigInteger counterSumValue = jobCounters.get(counterName).add(aggregatedCounters.get(counterName));
                    aggregatedCounters.put(counterName, counterSumValue);
                }
            }catch (Exception e){
                e.printStackTrace();
            }
        }
        System.out.println("Agg Counters: " + aggregatedCounters);

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
        System.out.println("Application ID: " + applicationId);

        RestTemplate restTemplate = new RestTemplate();
        String url = resourceManagerUrl;
        if(!resourceManagerUrl.endsWith("/"))
            url += "/";
        url += applicationId;

        // States taken from the following URL
        // https://hadoop.apache.org/docs/r2.6.0/hadoop-yarn/hadoop-yarn-site/ResourceManagerRest.html#Cluster_Application_API
        // All possible states: NEW, NEW_SAVING, SUBMITTED, ACCEPTED, RUNNING, FINISHED, FAILED, KILLED

      try {
          app = restTemplate.getForObject(url, Application.class);
          System.out.println("Application Status: " + app);
          while (!app.getApp().getState().equalsIgnoreCase("FINISHED") &&
                  !app.getApp().getState().equalsIgnoreCase("FAILED") &&
                  !app.getApp().getState().equalsIgnoreCase("KILLED")

                  ) {
              System.out.println("Application Status: " + app.getApp().getState());
              try {
                  System.out.println("Waiting for " + pollInterval + " milli sec for job " + jobId + " to complete");
                  Thread.sleep(pollInterval);
              } catch (InterruptedException e) {
                  e.printStackTrace();
                  return false;
              }
              app = restTemplate.getForObject(url, Application.class);

          }
      }catch (Exception e){
          System.out.println("Error: Failed to get application " + applicationId + "  status");
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




    public void setWorkloadId(String workloadId) {
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

    public Map<String, BigInteger> getAggregatedCounters() {
        return aggregatedCounters;
    }

    public void setAggregatedCounters(Map<String, BigInteger> aggregatedCounters) {
        this.aggregatedCounters = aggregatedCounters;
    }

    public String getTag() {
        return tag;
    }

    public void setTag(String tag) {
        this.tag = tag;
    }

    public String getOrigin() {
        return origin;
    }

    public void setOrigin(String origin) {
        this.origin = origin;
    }

    public Map<String, BigInteger> getAllCounters() {
        return allCounters;
    }

    public void setAllCounters(Map<String, BigInteger> allCounters) {
        this.allCounters = allCounters;
    }

    public int getJobsProcessed() {
        return jobsProcessed;
    }

    public void setJobsProcessed(int jobsProcessed) {
        this.jobsProcessed = jobsProcessed;
    }

    public boolean isException() {
        return isException;
    }

    public void setException(boolean exception) {
        isException = exception;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getFinishTime() {
        return finishTime;
    }

    public void setFinishTime(String finishTime) {
        this.finishTime = finishTime;
    }

    public long getTotalElapsedTime() {
        return totalElapsedTime;
    }

    public void setTotalElapsedTime(long totalElapsedTime) {
        this.totalElapsedTime = totalElapsedTime;
    }

    public long getTotalLatency() {
        return totalLatency;
    }

    public void setTotalLatency(long totalLatency) {
        this.totalLatency = totalLatency;
    }

    public String getAggregateJobId() {
        return aggregateJobId;
    }

    public void setAggregateJobId(String aggregateJobId) {
        this.aggregateJobId = aggregateJobId;
    }

    public String getWorkloadId() {
        return workloadId;
    }

    public List<AllTasks> getTasks() {
        return tasks;
    }

    public void setTasks(List<AllTasks> tasks) {
        this.tasks = tasks;
    }
}
