package com.sherpa.tunecore.joblauncher.com.sherpa.tunecore.joblauncher.hivecli;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Created by akhtar on 23/08/2015.
 */


public class HiveCliJobIdExtractor{

    private static final Logger log = LoggerFactory.getLogger(HiveCliJobIdExtractor.class);

    private HiveCliJobExecutor hiveJobExecutor;
    int totalJobsCount = 0;
    int jobIdsFetched = 0;



    public HiveCliJobIdExtractor(){
        this.hiveJobExecutor = HiveCliFactory.getHiveCliJobExecutorInstance();
    }


    public String extractJobIdFromLogLine(String line){
        String jobId="";

        if(hiveJobExecutor!=null){
            log.info("Sherpa Log Line: " + line);
            //System.out.println("************** Sherpa Log Line: " + line);
            // output contains the following words followed by job id
            if(line.contains("Total jobs")){
                totalJobsCount = getTotalJobsCount(line);
                hiveJobExecutor.setTotalJobs(totalJobsCount);
            }

            if(line.contains("Starting Job")){
                jobId = parseJobId(line);
                log.info("Sherpa Log Line: Found Job ID " + jobId);
                System.out.println("************* Sherpa Log Line: Found Job ID " + jobId);
                hiveJobExecutor.getJobQueue().add(jobId);
                jobIdsFetched++;
                //log.info("Hive Log Line Parsed Jobs " + jobIdsFetched + " out of " + totalJobsCount);
                //System.out.println("************* Sherpa Log Line: Parsed Jobs " + jobIdsFetched + " out of " + totalJobsCount);
                if(jobIdsFetched == totalJobsCount){
                    System.out.println("********** Sherpa Log Line: Parsed All Jobs " + jobIdsFetched + " out of " + totalJobsCount);
                    log.info("Sherpa Log Line: Parsed All Jobs " + jobIdsFetched + " out of " + totalJobsCount);
                    hiveJobExecutor.setIsJobsFinished(true);
                }
            }
        }
        return jobId;
    }




    private int getTotalJobsCount(String line){
        int totalJobsCount = 0;
        log.info("Parsing Total Jobs from line: " + line);
        String[] tok = line.split("=");
        if(tok.length == 2 ) {
            try {
                totalJobsCount = Integer.parseInt( tok[1].trim() );
                log.info("Parsed Total Jobs: " + totalJobsCount);
            }catch (NumberFormatException e){
                log.error("Error: Failed to parse total jobs ...");
                log.error(e.getMessage());
            }
        }

        return totalJobsCount;
    }



    private String parseJobId(String line){
        String jobId = "";
        log.info("Parsing Job ID From Line : " + line);
        String[] tok = line.split("=");
        if(tok.length >= 2 ) {
            try {
                jobId =  tok[1].trim();
                tok = jobId.split(",");
                jobId = tok[0].trim();
                log.info("Parsed Job ID: " + jobId);
            }catch (NumberFormatException e){
                log.error("Error: Failed to parse job id ...");
                log.error(e.getMessage());
            }
        }

        return jobId;
    }






}
