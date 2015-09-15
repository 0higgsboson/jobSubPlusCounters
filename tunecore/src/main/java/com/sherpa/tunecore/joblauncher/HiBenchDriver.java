package com.sherpa.tunecore.joblauncher;

/**
 * Created by akhtar on 11/08/2015.
 */


import com.sherpa.core.utils.ConfigurationLoader;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


public class HiBenchDriver {
    private static final Logger log = LoggerFactory.getLogger(JobExecutor.class);

    public static final int[] numberOfReducers  = new int[]{1,3,6,9,12,15,6,6,6,6,6,6};
    // public static final int[] numberOfMappers  = new int[]{1,3,6,9,12,15,6,6,6,6,6,6};
    //public static final int[] numberOfMappers = new int[]{18,18,18,18,18,18,1,3,9,18,27,81};
    //EK: Changed to more appropriate numbers on 9/14
    public static final int[] numberOfMappers = new int[]{4,8,16,32,64,128,256,512,768,1024};
    public static final int[] mapperMem  = new int[]{
            64,
            128,
            256,
            512,
            1024,
            2048,
            4096,
            1024,
            1024,
            1024,
            1024,
            1024,
            1024,
            1024
    };
    public static final int[] reducerMem = new int[]{
            1024,
            1024,
            1024,
            1024,
            1024,
            1024,
            1024,
            64,
            128,
            256,
            512,
            1024,
            2048,
            4096
    };



    public static final int[] mapperCores  = new int[]{
            1,
            2,
            3,
            4,
            1,
            1,
            1,
            1
    };
    public static final int[] reducerCores = new int[]{
            1,
            1,
            1,
            1,
            1,
            2,
            3,
            4
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
        HiBenchDriver driver = new HiBenchDriver();

        String sqlFile = args[0];
        long inputSize = Long.parseLong(args[1]);
        String outputDir = args[2];

        String appServer = ConfigurationLoader.getApplicationServerUrl();
        String jobHistoryServer = ConfigurationLoader.getJobHistoryUrl();
        int pollInterval = ConfigurationLoader.getPollInterval();


        Path path = new Path(outputDir);
        FileSystem fs = null;

        try {
            fs = FileSystem.get(new Configuration());
        } catch (IOException e) {
            e.printStackTrace();
        }

        try {



            System.out.println("\n\n\n Launching Jobs For Mapper & Reducer Settings Numbers");
            for(int i=0; i<HiBenchDriver.numberOfMappers.length; i++) {
                long splitSize = inputSize / HiBenchDriver.numberOfMappers[i];

                String config = "--hiveconf mapred.max.split.size=" + splitSize + " --hiveconf mapreduce.job.reduces="+ HiBenchDriver.numberOfReducers[i];
                System.out.print("\n\n\n Starting Executor with config: " + config);
                HiBenchJobExecutor executor = new HiBenchJobExecutor("", appServer, jobHistoryServer, pollInterval, config, sqlFile, HiBenchDriver.numberOfMappers[i]);
                executor.setWorkloadId(-1);
                executor.run();
            }



            System.out.println("\n\n\n Launching Jobs For Mapper & Reducer Memory");
            for(int i=0; i<HiBenchDriver.mapperMem.length; i++) {

                String config = "--hiveconf mapreduce.map.memory.mb=" + HiBenchDriver.mapperMem[i] + " --hiveconf mapreduce.reduce.memory.mb="+ HiBenchDriver.reducerMem[i];
                System.out.print("\n\n\n Starting Executor with config: " + config);
                HiBenchJobExecutor executor = new HiBenchJobExecutor("", appServer, jobHistoryServer, pollInterval, config, sqlFile, 0);
                executor.setWorkloadId(-1);
                executor.run();
            }


            System.out.println("\n\n\n Launching Jobs For Mapper & Reducer Core");
            for(int i=0; i<HiBenchDriver.mapperCores.length; i++) {

                String config = "--hiveconf mapreduce.map.cpu.vcores=" + HiBenchDriver.mapperCores[i] + " --hiveconf mapreduce.reduce.cpu.vcores="+ HiBenchDriver.reducerCores[i];
                System.out.print("\n\n\n Starting Executor with config: " + config);
                HiBenchJobExecutor executor = new HiBenchJobExecutor("", appServer, jobHistoryServer, pollInterval, config, sqlFile, 0);
                executor.setWorkloadId(-1);
                executor.run();
            }






        } catch (Exception e) {
            e.printStackTrace();
        }




    }




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


    }



}
