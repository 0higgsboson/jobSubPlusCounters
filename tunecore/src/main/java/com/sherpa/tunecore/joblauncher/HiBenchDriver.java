package com.sherpa.tunecore.joblauncher;

/**
 * Created by akhtar on 11/08/2015.
 */


import com.sherpa.core.utils.ConfigurationLoader;
//import org.apache.hadoop.conf.Configuration;
//import org.apache.hadoop.fs.FileSystem;
//import org.apache.hadoop.fs.Path;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

//import java.io.IOException;


public class HiBenchDriver {
    private static final Logger log = LoggerFactory.getLogger(HiBenchDriver.class);

    // The following are used in  manner where the Mappers array is iterated upon
    // and is used to index into the Reduce array. This approach will not generate
    // a matrix of all combinations. Below, we have same variables but with unique
    // values for each index (position)
    /*
    private static final int[] numberOfReducers  = {
    	    1,3,6,9,12,15,18,7,7,7
    };
  
    private static final int[] numberOfMappers = {
    	    4,8,16,32,64,128,256,512,768,1024
    };
    
    private static final int[] mapperMem  = {
    		64,128,256,512,1024,2048,4096,1024,1024,1024,1024,1024,1024
    };
    
    private static final int[] reducerMem = {
            1024,1024,1024,1024,1024,1024,1024,64,128,256,512,2048,4096
    };
    
    private static final int[] mapperCores  = {
            1,2,3,4,1,1,1
    };
    
    public static final int[] reducerCores = {
            1,1,1,1,2,3,4
    };
    */
    
    private static final int[] numberOfReducersUniq  = {
	    1,3,6,9,13,15,17,18
    };

    private static final int[] numberOfMappersUniq = {
	    4,8,16,32,64,128,256,512,768,1024
    };

    private static final int[] mapperMemUniq  = {
		64,128,256,512,1024,2048,4096
    };

    private static final int[] reducerMemUniq = {
        64,128,256,512,1024,2048,4096
    };

    private static final int[] mapperCoresUniq  = {
        1,2,3,4
    };

    public static final int[] reducerCoresUniq = {
        1,2,3,4
    };
    
    public HiBenchDriver(){
    }

    public static void main(String args[]) {
        //System.out.print(ConfigurationLoader.getJobHistoryUrl());
        parseArgsAndRunJob(args);
    }


    public static void parseArgsAndRunJob(String[] args){
        if(args==null || args.length !=3) {
            log.info("Usage: SQL_File  Input_Size_In_Bytes HDFS_Output_Dir");
            System.exit(1);
        }
      
        String sqlFile = args[0];
        long inputSize = Long.parseLong(args[1]);
        String outputDir = args[2];

        String appServer = ConfigurationLoader.getApplicationServerUrl();
        String jobHistoryServer = ConfigurationLoader.getJobHistoryUrl();
        int pollInterval = ConfigurationLoader.getPollInterval();


        //Path path = new Path(outputDir);
        //FileSystem fs = null;

        //try {
         //   fs = FileSystem.get(new Configuration());
       //} catch (IOException e) {
        //    e.printStackTrace();
        //    log.debug("Error in opening config file: "+e);
        //}

        try {
        	String config;
        	/*
        	log.info("==============================================");
            log.info("Launching Jobs For Mapper & Reducer Settings Numbers...");
            for(int i=0; i< numberOfMappers.length; i++) {
                long splitSize = inputSize / numberOfMappers[i];

                config = "--hiveconf mapred.max.split.size=" + splitSize + " --hiveconf mapreduce.job.reduces="+ numberOfReducers[i];
                log.info("...Starting Executor with config: " + config);
                HiBenchJobExecutor executor = new HiBenchJobExecutor("", appServer, jobHistoryServer, pollInterval, config, sqlFile, numberOfMappers[i]);
                executor.setWorkloadId(-1);
                executor.run();
            }
            log.info("Done with Jobs For Mapper & Reducer Settings Numbers");


            log.info("==============================================");
            log.info("Launching Jobs For Mapper & Reducer Memory...");
            for(int i=0; i<mapperMem.length; i++) {

                config = "--hiveconf mapreduce.map.memory.mb=" + HiBenchDriver.mapperMem[i] + " --hiveconf mapreduce.reduce.memory.mb="+ reducerMem[i];
                log.info("...Starting Executor with config: " + config);
                HiBenchJobExecutor executor = new HiBenchJobExecutor("", appServer, jobHistoryServer, pollInterval, config, sqlFile, 0);
                executor.setWorkloadId(-1);
                executor.run();
            }
            log.info("Done with Jobs For Mapper & Reducer Memory");

            log.info("==============================================");
            log.info("Launching Jobs For Mapper & Reducer Core...");
            for(int i=0; i<mapperCores.length; i++) {

                config = "--hiveconf mapreduce.map.cpu.vcores=" + HiBenchDriver.mapperCores[i] + " --hiveconf mapreduce.reduce.cpu.vcores="+ reducerCores[i];
                log.info("...Starting Executor with config: " + config);
                HiBenchJobExecutor executor = new HiBenchJobExecutor("", appServer, jobHistoryServer, pollInterval, config, sqlFile, 0);
                executor.setWorkloadId(-1);
                executor.run();
            }
            log.info("Done with Jobs For Mapper & Reducer Core");
            */
        	long splitSize;
        	
        	log.info("==============================================");
            log.info("Launching Jobs For Mapper & Reducer Settings Numbers...");
            for(int i=0; i< numberOfMappersUniq.length; i++) {
            	for(int j = 0; j<numberOfReducersUniq.length; j++){
            		splitSize = inputSize / numberOfMappersUniq[i];

            		config = "--hiveconf mapred.max.split.size=" + splitSize + " --hiveconf mapreduce.job.reduces="+ numberOfReducersUniq[j];
            			
            		log.info("...Starting Executor with config: " + config);
            			
            		HiBenchJobExecutor executor = new HiBenchJobExecutor("", appServer, jobHistoryServer, pollInterval, config, sqlFile, numberOfMappersUniq[i]);
            		executor.setWorkloadId(-1);
            		executor.run();
            	}
            }
            log.info("Done with Jobs For Mapper & Reducer Settings Numbers");


            log.info("==============================================");
            log.info("Launching Jobs For Mapper & Reducer Memory...");
            for(int i=0; i<mapperMemUniq.length; i++) {
            	for(int j=0; j<reducerMemUniq.length; j++){

            		config = "--hiveconf mapreduce.map.memory.mb=" + HiBenchDriver.mapperMemUniq[i] + " --hiveconf mapreduce.reduce.memory.mb="+ reducerMemUniq[j];
            		
            		log.info("...Starting Executor with config: " + config);
                
            		HiBenchJobExecutor executor = new HiBenchJobExecutor("", appServer, jobHistoryServer, pollInterval, config, sqlFile, 0);
            		executor.setWorkloadId(-1);
            		executor.run();
            	}
            }
            log.info("Done with Jobs For Mapper & Reducer Memory");

            log.info("==============================================");
            log.info("Launching Jobs For Mapper & Reducer Core...");
            for(int i=0; i<mapperCoresUniq.length; i++) {
            	for(int j=0; j<mapperCoresUniq.length; j++) {
            		config = "--hiveconf mapreduce.map.cpu.vcores=" + HiBenchDriver.mapperCoresUniq[i] + " --hiveconf mapreduce.reduce.cpu.vcores="+ reducerCoresUniq[j];
            		
            		log.info("...Starting Executor with config: " + config);
            		
            		HiBenchJobExecutor executor = new HiBenchJobExecutor("", appServer, jobHistoryServer, pollInterval, config, sqlFile, 0);
            		executor.setWorkloadId(-1);
            		executor.run();
            	}
            }
            log.info("Done with Jobs For Mapper & Reducer Core");

        } catch (Exception e) {
            e.printStackTrace();
            log.error("Error in executing: "+e);
        }
        log.info("====Done with entire run=======");
    }

   /*
    public static void run(String cmd, int wid){

        String appServer = ConfigurationLoader.getApplicationServerUrl();
        String jobHistoryServer = ConfigurationLoader.getJobHistoryUrl();
        int pollInterval = ConfigurationLoader.getPollInterval();

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


    }*/



}
