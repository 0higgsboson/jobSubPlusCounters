package com.sherpa.tunecore.joblauncher.com.sherpa.tunecore.joblauncher.hivecli;

import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.dao.WorkloadCountersConfigurations;
import com.sherpa.tunecore.entitydefinitions.job.execution.Application;
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

    public HiveCliJobExecutor(String fileLines, String rmUrl, String historyServer, int pollInterval){
        this.fileLines = fileLines;
        this.resourceManagerUrl = rmUrl;
        this.historyServerUrl     = historyServer;
        this.pollInterval = pollInterval;

        date = new Date();
        workloadManager = new WorkloadCountersManager();
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

                Map<String, BigInteger> jobCounters = getTaskCounters(jobId);
                if(jobCounters!=null) {
                    saveWorkloadCounters(jobId, elapsedTime, jobCounters);
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


            saveWorkloadCounters(aggregateJobId, totalElapsedTime, jobCountersMap);
            workloadManager.close();
            log.info("Finished All Tasks ... " + jobsProcessed);
            System.out.println("Finished All Tasks ... " + jobsProcessed);
        }

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




    private void saveWorkloadCounters(String jobId, long elapsedTime, Map<String, BigInteger> jobCounters){
        log.info("Saving Counters into Phoenix Table For Job ID: " + jobId);
        System.out.println("Saving Counters into Phoenix Table For Job ID: " + jobId);

        workloadManager.saveCounters(workloadId, date, (int) elapsedTime, jobId, WorkloadCountersConfigurations.JOB_TYPE_HIVE, jobCounters);
        log.info("Done Saving Counters into Phoenix For Job ID: " + jobId);
        System.out.println("Done Saving Counters into Phoenix For Job ID: " + jobId);
        workloadManager.close();
    }


    public void addToCounters(Map<String, BigInteger> jobCounters){
        Iterator<String> counters = jobCounters.keySet().iterator();
        while(counters.hasNext()){
            String counterName = counters.next();
            try {
                BigInteger counterSumValue = jobCounters.get(counterName).add(jobCountersMap.get(counterName));
                jobCountersMap.put(counterName, counterSumValue);
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
}
