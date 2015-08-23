package com.sherpa.tunecore.joblauncher;

/**
 * Created by akhtar on 11/08/2015.
 */


/**
 *
 * Here is what you need to run it

 1. Define configuration file, there is a sample configuration file provided with this project, named rest.conf, change configurations as per your requirements and place it in a dir

 2. Change configuration file path in Class com.performancesherpa.joblauncher.Driver, find under configurationBasedRun method.

 3. Compile and build a jar and run it.


 Here is the sample configuration and commands to run on master node:

 1. Config file path: /home/akhtar_mdin/rest.conf
 2. Code checkout dir: /root/tunecore2/tunecore
 3. Run with

 /usr/lib/jvm/java-7-oracle-cloudera/jre/bin/java -Dlog4j.configuration=file:///root/tunecore2/tunecore/log4j.properties -jar
 /root/tunecore2/tunecore/target/tunecore-1.0-SNAPSHOT-jar-with-dependencies.jar sudo
 yarn jar /opt/cloudera/parcels/CDH-5.4.4-1.cdh5.4.4.p0.4/lib/hadoop/share/hadoop/mapreduce2/hadoop-mapreduce-examples-2.6.0-cdh5.4.4.jar pi 16 10

 4. find output files under storage dir defined in configuration file

 *
 *
 *
 */



public class Driver {



    public static void main(String args[]) {
       parseArgsAndRunJob(args);
        //testRun();
    }


    public static void parseArgsAndRunJob(String[] args){
        if(args==null || args.length==0) {
            System.out.println("Type YARN command to be run");
            return;
        }

        String cmd = "";
        if(args.length > 1 ){
            for(String arg: args){
                cmd += arg + " ";
            }
        }
        else{
            cmd = args[0].replace("\"", "");
        }

        cmd.trim();
        System.out.println("Command: " + cmd);
        configurationBasedRun(cmd);
    }




    public static void configurationBasedRun(String cmd){
        String confPath = "/home/akhtar_mdin/rest.conf";
        ConfigurationLoader configs = new ConfigurationLoader();
        configs.loadConfigurations(confPath);

        //String cmd = "sudo yarn jar /Users/akhtar/Downloads/hadoop/hadoop-2.7.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.0.jar pi 16 10";
        String appServer = configs.getApplicationServerUrl();
        String jobHistoryServer = configs.getJobHistoryUrl();
        String storageDir = configs.getStorageDir();

        JobExecutor executor = new JobExecutor(cmd, appServer, jobHistoryServer, storageDir);
        executor.start();

    }



    public static void testRun(){
        String cmd = "sudo yarn jar /Users/akhtar/Downloads/hadoop/hadoop-2.7.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.0.jar pi 16 10000000";
        String appServer = "http://localhost:8088/ws/v1/cluster/apps";
        String jobHistoryServer = "http://localhost:19888/ws/v1/history/mapreduce/jobs";
        String storageDir = "/Users/akhtar/Downloads/json/";

        JobExecutor executor = new JobExecutor(cmd, appServer, jobHistoryServer, storageDir);
        executor.start();

    }



}
