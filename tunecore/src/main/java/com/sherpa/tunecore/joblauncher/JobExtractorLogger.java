package com.sherpa.tunecore.joblauncher;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Created by akhtar on 23/08/2015.
 */


public class JobExtractorLogger extends  Thread{
    private static final Logger log = LoggerFactory.getLogger(JobExtractorLogger.class);

    private Process process;


    public JobExtractorLogger(Process process){
        this.process = process;
    }


    public void run(){
        BufferedReader br = null;


        try {
            br = new BufferedReader(new InputStreamReader(process.getErrorStream()));
            String line = null;

            while( (line=br.readLine()) !=null ){
                log.info("Log Line: " + line);
            } // ends while loop


        } catch (IOException e) {
            e.printStackTrace();
            log.error(e.getMessage());
            log.error("Error in  Job Extractor Logger");
        }
        finally {
            try {
                br.close();
            } catch (IOException e) {
                e.printStackTrace();
                log.error(e.getMessage());
            }
        }

        log.info("***** Terminating Job  Extractor Thread ...");
    }






}
