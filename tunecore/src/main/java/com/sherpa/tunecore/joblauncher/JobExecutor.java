package com.sherpa.tunecore.joblauncher;

import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.entitydefinitions.WorkloadCounters;
import com.sherpa.core.utils.DateTimeUtils;
import com.sherpa.tunecore.entitydefinitions.job.execution.Application;
import com.sherpa.tunecore.metricsextractor.mapreduce.HistoricalJobCounters;
import com.sherpa.tunecore.metricsextractor.mapreduce.HistoricalTaskCounters;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.client.RestTemplate;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Created by akhtar on 10/08/2015.
 */


/**
 * Accepts a YARN job command
 * Launches the job
 * Polls the job status after pollInterval
 * On completion, saves counters data to files
 */




public class JobExecutor extends Thread{
    private static final Logger log = LoggerFactory.getLogger(JobExecutor.class);
    // yarn command to be executed
    private String command;
    // resource manager url to track application status
    private String resourceManagerUrl;
    // job history server url to pull counters data
    private String historyServerUrl;
    // keeps application's run time status
    private Application app;
    // workload ID
    private int workloadId=-1;

    private int pollInterval = 5000;

    public JobExecutor(String cmd, String rmUrl, String historyServer, int pollInterval){
        this.command = cmd;
        this.resourceManagerUrl = rmUrl;
        this.historyServerUrl     = historyServer;
        this.pollInterval = pollInterval;
    }


    /**
     *  Implements the controlling part of the job execution, tracking and saving
     */
    public void run(){
        log.info("Started Job Executor");

        // Execute the command and gets its process
        log.info("Executing command ...");
        Process process = launchCommand(this.command);
        if(process==null){
            log.info("Could not execute job, please check your command");
            return;
        }


        // Scraps the job ID from the process output stream
        log.info("Scraping application id ...");
        String jobId = getApplicationId(process);
        if(jobId==null || jobId.isEmpty()){
            log.info("Error: Job ID empty");
            return;
        }

        // start logging
        new JobExtractorLogger(process).start();

        // waits for job/application to complete
        log.info("Waiting for application to complete");
        boolean appStatus = waitForCompletion(jobId);

        // Saves counters data only when job is successfull
        if(appStatus){

            long elapsedTime = getElapsedTime();
            log.info("Elapsed Time: " + elapsedTime);

            // Saves workload counters into hbase
            saveWorkloadCounters(jobId, elapsedTime);

            log.info("Finished Saving Data ...");
        }

        log.info("Finished All Tasks ...");

    }




    private void saveWorkloadCounters(String jobId, long elapsedTime){
        // Collecting Performance Counters

        HistoricalTaskCounters historicalTaskCounters = new HistoricalTaskCounters(historyServerUrl);
        try {
            historicalTaskCounters.getJobCounters(jobId);
        }catch (Exception e){
            e.printStackTrace();
        }
        WorkloadCountersManager mgr = new WorkloadCountersManager();


        // to save into hbase
/*
        WorkloadCounters performanceCounters = new WorkloadCounters();
        performanceCounters.setElapsedTime(elapsedTime);
        performanceCounters.setCpu(historicalTaskCounters.getCPUMSec().toString());
        performanceCounters.setMemory(historicalTaskCounters.getPMemBytes().toString());
        log.info("Performance Counters: " + performanceCounters.toString());

        log.info("Saving Counters into Hbase ...");
        mgr.saveWorkloadCounters(workloadId, DateTimeUtils.convertDateTimeStringToTimestamp(DateTimeUtils.getCurrentDateTime()), jobId, performanceCounters);
        log.info("Done Saving Counters into Hbase ...");
*/


        log.info("Saving Counters into Phoenix Table ...");
        mgr.saveCounters(workloadId, jobId, historicalTaskCounters.getCounterValues());
        log.info("Done Saving Counters into Phoenix ...");
        mgr.close();




    }




    private Process launchCommand(String command){
        Process process = null;
        try {
             process = Runtime.getRuntime().exec(command);
        } catch (IOException e) {
            e.printStackTrace();
            log.error(e.getMessage());
        }

        return process;
    }


    private String getApplicationId(Process process){
        String jobId = null;
        BufferedReader br = null;
        try {
            br = new BufferedReader(new InputStreamReader(process.getErrorStream()));
            String line = null;

            while( (line=br.readLine()) !=null ){
                log.info("Log Line: " + line);
               // output contains the following words followed by job id
               if(line.contains("Running job")){
                   String[] tok = line.split(":");
                   if(tok.length >=1 ) {
                       jobId = tok[tok.length - 1].trim();
                       log.info("Job ID: " + jobId);
                       break;
                   }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
            log.error(e.getMessage());
        }
        finally {
            /*try {
                br.close();
            } catch (IOException e) {
                e.printStackTrace();
                log.error(e.getMessage());
            }*/
        }

        return jobId;
    }


    private boolean waitForCompletion(String jobId){
        // YARN uses the word application instead of job, so replacing job with application
        String applicationId = jobId.replace("job", "application");
        log.info("Application ID: " + applicationId);

        RestTemplate restTemplate = new RestTemplate();

        if(!resourceManagerUrl.endsWith("/"))
            resourceManagerUrl += "/";

        resourceManagerUrl += applicationId;

        app = restTemplate.getForObject(resourceManagerUrl, Application.class);


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
                Thread.sleep(pollInterval);
            } catch (InterruptedException e) {
                e.printStackTrace();
                return false;
            }
            app = restTemplate.getForObject(resourceManagerUrl, Application.class);

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



    @Deprecated
    public long getElapsedTime(String jobId){
        long elapsedTime=0;

        // YARN uses the word application instead of job, so replacing job with application
        String applicationId = jobId.replace("job", "application");
        log.info("Getting elapsed time");
        log.info("Application ID: " + applicationId);

        RestTemplate restTemplate = new RestTemplate();

        if(!resourceManagerUrl.endsWith("/"))
            resourceManagerUrl += "/";

        resourceManagerUrl += applicationId;

        Application app = restTemplate.getForObject(resourceManagerUrl, Application.class);
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




}
