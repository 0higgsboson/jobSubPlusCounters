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

    public static void  extractJobIdFromLogLine(String line){
        // output contains the following words followed by job id
        if(line.contains("Total jobs")){
            System.out.println("HiveCliJobIdExtractor: Total Jobs Line Found ...");
            if(HiveCliFactory.getHiveCliJobExecutorInstance() != null )
                HiveCliFactory.getHiveCliJobExecutorInstance().setTotalJobs(getTotalJobsCount(line));
            else
                System.out.println("HiveCliJobIdExtractor:  HiveCliJobExtractor null, cant push total jobs count...");

        }

        if(line.contains("Starting Job")){
            System.out.println("HiveCliJobIdExtractor: Starting Job Line Found ...");
            if(HiveCliFactory.getHiveCliJobExecutorInstance() != null ) {
                String jobId = parseJobId(line);
                log.info("Sherpa Log Line: Found Job ID " + jobId);
                System.out.println("************* Sherpa Log Line: Found Job ID " + jobId);
                HiveCliFactory.getHiveCliJobExecutorInstance().getJobQueue().add(jobId);
            }
            else
                System.out.println("HiveCliJobIdExtractor:  HiveCliJobExtractor null, cant push job id ...");

        }

    }




    private static int getTotalJobsCount(String line){
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



    private static String parseJobId(String line){
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
