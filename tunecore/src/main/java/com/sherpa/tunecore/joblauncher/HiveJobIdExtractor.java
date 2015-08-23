package com.sherpa.tunecore.joblauncher;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Created by akhtar on 23/08/2015.
 */


public class HiveJobIdExtractor extends  Thread{
    private static final Logger log = LoggerFactory.getLogger(HiveJobIdExtractor.class);

    private HiveJobExecutor hiveJobExecutor;
    private Process process;


    public HiveJobIdExtractor(HiveJobExecutor hje, Process process){
        this.hiveJobExecutor = hje;
        this.process = process;
    }


    public void run(){
        int totalJobsCount = 0;
        int jobIdsFetched = 0;
        BufferedReader br = null;


        try {
            br = new BufferedReader(new InputStreamReader(process.getErrorStream()));
            String line = null;

            while( (line=br.readLine()) !=null ){

                log.info("Hive Log Line: " + line);
                // output contains the following words followed by job id
                if(line.contains("Total jobs")){
                    totalJobsCount = getTotalJobsCount(line);
                }

                if(line.contains("Starting Job")){
                    String jobId = parseJobId(line);
                    hiveJobExecutor.getJobQueue().add(jobId);
                    log.info("*** Parsed Jobs " + jobIdsFetched + " out of " + totalJobsCount);
                    jobIdsFetched++;

                    if(jobIdsFetched == totalJobsCount){
                        log.info("Parsed All Jobs " + jobIdsFetched + " out of " + totalJobsCount);
                        hiveJobExecutor.setIsJobsFinished(true);
                        break;
                    }

                }

            } // ends while loop





        } catch (IOException e) {
            e.printStackTrace();
            log.error(e.getMessage());
            log.error("Error in Hive Job ID Extractor");
        }
        finally {
            try {
                br.close();
                hiveJobExecutor.setIsJobsFinished(true);
            } catch (IOException e) {
                e.printStackTrace();
                log.error(e.getMessage());
            }
        }

        log.info("***** Terminating Hive Job ID Extractor Thread ...");
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
