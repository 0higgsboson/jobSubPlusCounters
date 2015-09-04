package com.sherpa.tunecore.joblauncher;

/**
 * Created by akhtar on 11/08/2015.
 */


import org.apache.hadoop.conf.Configuration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class WorkloadDriver {
    private static final Logger log = LoggerFactory.getLogger(JobExecutor.class);



    public static void main(String args[]) {
        parseArgsAndRunJob(args);
    }


    public static void parseArgsAndRunJob(String[] args){
        if(args==null || args.length <=1) {
            log.info("Error: Minimum two parameters are required");
            log.info("Usage: WorkloadId YARN_Command");
            System.exit(1);
        }

        String cmd = "";

        int wid = 0;
        try {
            wid = Integer.parseInt(args[0]);
            if (wid < 0) {
                log.info("Workload ID should be greater than 0");
                System.exit(1);
            }
        }catch (NumberFormatException e){
            log.info("Workload ID should be an integer");
            System.exit(1);
        }


        System.out.println("Workload ID: " + wid);
        if(args.length > 2 ){
            log.info("Forming Command: ");
            for(int i=1; i<args.length; i++){
                cmd += args[i] + " ";
            }
        }
        else{
            log.info("Single Command");
            cmd = args[1];
        }

        log.info("Command: " + cmd);
        run(cmd, wid);
    }




    public static void run(String cmd, int wid){
        ConfigurationLoader configs = new ConfigurationLoader();
        configs.loadDefaultConfigurations();

        String appServer = configs.getApplicationServerUrl();
        String jobHistoryServer = configs.getJobHistoryUrl();
        int pollInterval = configs.getPollInterval();

        if(cmd.contains("hive")) {
            HiveJobExecutor executor = new HiveJobExecutor(cmd, appServer, jobHistoryServer, pollInterval);
            executor.setWorkloadId(wid);
            executor.start();
        }
        else{
            JobExecutor executor = new JobExecutor(cmd, appServer, jobHistoryServer, pollInterval);
            executor.setWorkloadId(wid);
            executor.start();
        }


    }



}
