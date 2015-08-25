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
import java.math.BigInteger;
import java.util.LinkedList;
import java.util.Queue;

/**
 * Created by akhtar on 10/08/2015.
 */


/**
 * Accepts a YARN job command
 * Launches the job
 * Polls the job status after pollInterval
 * On completion, saves counters data to files
 */




public class HiveJobExecutor extends Thread{
    private static final Logger log = LoggerFactory.getLogger(HiveJobExecutor.class);
    // yarn command to be executed
    private String command;
    // resource manager url to track application status
    private String applicationServerUrl;
    // job history server url to pull counters data
    private String historyServerUrl;
    // interval after which job/application status is checked
    private int pollInterval;
    // dir where counters data is saved in files
    private String storageDir;
    // keeps application's run time status
    private Application app;
    // workload ID
    private int workloadId=-1;

    // to collect  task counters
    private HistoricalTaskCounters historicalTaskCounters;


    private HiveJobIdExtractor hiveJobIdExtractor;
    // Hive Job Extractor Thread adds jobs id in that queue
    private Queue<String> jobQueue = new LinkedList<String>();
    // // Hive Job Extractor Thread sets it to true once all job ids are added in the queue
    private boolean isJobsFinished=false;

    BigInteger PMemBytes = new BigInteger("0");
    BigInteger CPUMSec = new BigInteger("0");
    long totalElapsedTime = 0;

    private String mrJobId = "";


    public HiveJobExecutor(String cmd, String appServer, String historyServer, String storageDir, int pollInterval){
        this.command = cmd;
        this.applicationServerUrl = appServer;
        this.historyServerUrl     = historyServer;
        this.storageDir = storageDir;
        this.pollInterval = pollInterval;

    }

    public HiveJobExecutor(String cmd, String appServer, String historyServer, String storageDir){
        this.command = cmd;
        this.applicationServerUrl = appServer;
        this.historyServerUrl     = historyServer;
        this.storageDir = storageDir;
        this.pollInterval = 5 * 1000;  // default 5 sec

    }


    /**
     *  Implements the controlling part of the job execution, tracking and saving
     */
    public void run(){

        // Execute the command and gets its process
        log.info("Executing command ...");
        Process process = launchCommand(this.command);
        if(process==null){
            log.info("Could not execute job, please check your command");
            return;
        }

        // start a new thread to parse job id's from hive command logs
        hiveJobIdExtractor          = new HiveJobIdExtractor(this, process);
        hiveJobIdExtractor.start();

        int jobsProcessed = 0;


        // process until job id extractor is terminated and job queue is empty
        while( isJobsFinished==false || !jobQueue.isEmpty() ) {

            int waitCount = 0;
            while(jobQueue.isEmpty()){
                if(isJobsFinished)
                    break;

                try {
                    log.info("Waiting For More Jobs To Come ...");
                    waitCount +=1000;
                    Thread.sleep(1000);
                }catch (InterruptedException e){
                    log.error(e.getMessage());
                }

                if(waitCount >= (1000 * 60) ){
                    log.info("Waited for a minute, no new job came,  ...");
                    break;
                }
            }


            if(jobQueue.isEmpty()){
                log.info("No new job to process, shutting down ...");
                break;
            }


            String jobId = jobQueue.remove();
            if (jobId == null || jobId.isEmpty()) {
                log.info("Error: Job ID Empty");
                continue;
            }

            if(mrJobId.isEmpty())
                mrJobId = jobId;

            log.info("Processing Job: " + jobId);

            // waits for job/application to complete
            log.info("Waiting for application to complete");
            boolean appStatus = waitForCompletion(jobId);

            // Saves counters data only when job is successfull
            if (appStatus) {
                long elapsedTime = getElapsedTime();
                log.info("Elapsed Time: " + elapsedTime);
                log.info("Adding Elapsed Time:  " +  totalElapsedTime + " + " + elapsedTime);
                totalElapsedTime += elapsedTime;
                log.info("Running Elapsed Time:  " + totalElapsedTime);

                // Saves task counters
                log.info("Getting Task Counters ...");
                getTaskCounters(jobId);

                log.info("Total Jobs Processed: " + jobsProcessed++);
                log.info("Finished Getting Task Counter for job " + jobId);
            }



        }// main while loop


        // Saves workload counters into hbase
        if(jobsProcessed > 0)
              saveWorkloadCounters();
        log.info("Finished All Tasks ... " + jobsProcessed);


    }


    private void getTaskCounters(String jobId){
        try {
            historicalTaskCounters = new HistoricalTaskCounters(storageDir, historyServerUrl);
            historicalTaskCounters.getJobCounters(jobId);

            log.info("Adding CPU Time: " + CPUMSec.toString() + " + " + historicalTaskCounters.getCPUMSec().toString());
            CPUMSec = CPUMSec.add(historicalTaskCounters.getCPUMSec());
            log.info("Running CPU Time: " + CPUMSec.toString());

            log.info("Adding Memory: " + PMemBytes.toString() + " + " + historicalTaskCounters.getPMemBytes().toString());
            PMemBytes = PMemBytes.add( historicalTaskCounters.getPMemBytes());
            log.info("Collective Memory: " +  PMemBytes.toString() );


        } catch (Exception e) {
            e.printStackTrace();
        }
    }




    private void saveWorkloadCounters(){
        // Collecting Performance Counters
        WorkloadCounters performanceCounters = new WorkloadCounters();
        performanceCounters.setElapsedTime(totalElapsedTime);
        performanceCounters.setCpu(CPUMSec.toString());
        performanceCounters.setMemory(PMemBytes.toString());
        log.info("Performance Counters: " + performanceCounters.toString());

        // if workload id is defined then save into bhase
        if(workloadId > 0) {
            WorkloadCountersManager mgr = new WorkloadCountersManager();
            log.info("Saving Counters into Hbase ...");
            mgr.saveWorkloadCounters(workloadId, DateTimeUtils.convertDateTimeStringToTimestamp(DateTimeUtils.getCurrentDateTime()), mrJobId,  performanceCounters);
            log.info("Done Saving Counters into Hbase ...");
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

        String url = applicationServerUrl;
        if(!applicationServerUrl.endsWith("/"))
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




}
