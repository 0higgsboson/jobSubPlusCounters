package com.sherpa.tunecore.joblauncher;

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
    private String resourceManagerUrl;
    // job history server url to pull counters data
    private String historyServerUrl;
    // interval after which job/application status is checked
    private int pollInterval;
    // keeps application's run time status
    private Application app;
    // workload ID
    private int workloadId=-1;


    private HiveJobIdExtractor hiveJobIdExtractor;
    // Hive Job Extractor Thread adds jobs id in that queue
    private Queue<String> jobQueue = new LinkedList<String>();
    // // Hive Job Extractor Thread sets it to true once all job ids are added in the queue
    private boolean isJobsFinished=false;

    private long totalElapsedTime = 0;
    private Map<String, Map<String, BigInteger> > jobCountersMap = new HashMap<String, Map<String, BigInteger> >();
    private String mrJobId = "";
    private String aggregateJobId = "";

    private WorkloadCountersManager workloadManager;
    private Date date;


    public HiveJobExecutor(String cmd, String rmUrl, String historyServer, int pollInterval){
        this.command = cmd;
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

        log.info("Command: " + command);
        String hiveQueryFilePath = getFilePath(this.command);
        log.info("Hive File Path: " + hiveQueryFilePath);
        if(hiveQueryFilePath.isEmpty()){
            log.error("Error: Hive file path for queries not found ...");
            workloadManager.close();
            System.exit(1);
        }
        workloadId = workloadManager.getFileWorkloadID(hiveQueryFilePath);
        if(workloadId<0){
            log.error("Error: could not generate worklod id ...");
            workloadManager.close();
            System.exit(1);
        }

        // Execute the command and gets its process
        log.info("Executing command: " + this.command);
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
                Map<String, BigInteger> jobCounters = getTaskCounters(jobId);
                if(jobCounters!=null) {
                    jobCountersMap.put(jobId, jobCounters);
                    saveWorkloadCounters(jobId, elapsedTime, jobCounters);
                }

                if(aggregateJobId.isEmpty())
                    aggregateJobId=jobId;
                else
                    aggregateJobId += ":" + jobId;


                log.info("Total Jobs Processed: " + ++jobsProcessed);
                log.info("Finished Getting Counters for job " + jobId);
            }



        }// main while loop

        log.info("Saving Aggregated Counters For " + jobsProcessed + " Jobs");
        Map<String, BigInteger> aggCounters = getAggregatedCounters();
        saveWorkloadCounters(aggregateJobId, totalElapsedTime, aggCounters);
        workloadManager.close();
        log.info("Finished All Tasks ... " + jobsProcessed);

    }


    private String getFilePath(String command){
        if(command==null || command.isEmpty())
            return "";

        String filePath = "";
        String[] cmdTokens = command.split(" ");
        for(int i=0; i<cmdTokens.length; i++){
            if(cmdTokens[i].equalsIgnoreCase("-f")){
                if( (i+1)<cmdTokens.length ){
                    filePath = cmdTokens[i+1];
                    log.info("Hive Query File Path Found: " + filePath);
                    break;
                }
            }
        }
        return filePath;
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
        workloadManager.saveCounters(workloadId, date, (int) elapsedTime, jobId, WorkloadCountersConfigurations.JOB_TYPE_HIVE,jobCounters);
        log.info("Done Saving Counters into Phoenix For Job ID: " + jobId);
        workloadManager.close();
    }


    public Map<String, BigInteger> getAggregatedCounters(){
        Map<String, BigInteger> aggs = WorkloadCountersConfigurations.getInitialCounterValuesMap();

        Iterator<String> counters = aggs.keySet().iterator();
        while(counters.hasNext()){
            String counterName = counters.next();
            BigInteger counterSumValue = aggs.get(counterName);

            for(Map.Entry<String, Map<String, BigInteger>> jobCounters: jobCountersMap.entrySet()){
                if(jobCounters.getValue().containsKey(counterName))
                     counterSumValue = counterSumValue.add(jobCounters.getValue().get(counterName));
            }

            aggs.put(counterName, counterSumValue);

        }

        return aggs;
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
