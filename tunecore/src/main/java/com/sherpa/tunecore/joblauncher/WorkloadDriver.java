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



public class WorkloadDriver {



    public static void main(String args[]) {
       parseArgsAndRunJob(args);
    }


    public static void parseArgsAndRunJob(String[] args){
        if(args==null || args.length <=1) {
            System.out.println("Minimum two parameters are required");
            System.out.println("Usage: workloadId Yarn_Command");

            return;
        }

        String cmd = "";
        int wid = Integer.parseInt(args[0]);
        System.out.println("Workload ID: " + wid);
        if(args.length > 2 ){
            System.out.println("Forming Command: ");
            for(int i=1; i<args.length; i++){
                cmd += args[i] + " ";
            }
        }
        else{
            System.out.println("Single Command");
            cmd = args[1];
        }

        //cmd = "hive -e \"CREATE TABLE wc_large AS SELECT word, count(1) AS count FROM (SELECT explode(split(line, '\\s')) AS word FROM docs_large) w GROUP BY word ORDER BY word;\"";



        System.out.println("Command: " + cmd);
        configurationBasedRun(cmd, wid);
    }




    public static void configurationBasedRun(String cmd, int wid){
        String confPath = "/home/akhtar_mdin/rest.conf";
        ConfigurationLoader configs = new ConfigurationLoader();
        configs.loadConfigurations(confPath);

        //String cmd = "sudo yarn jar /Users/akhtar/Downloads/hadoop/hadoop-2.7.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.0.jar pi 16 10";
        String appServer = configs.getApplicationServerUrl();
        String jobHistoryServer = configs.getJobHistoryUrl();
        String storageDir = configs.getStorageDir();



        if(cmd.contains("hive")) {
            HiveJobExecutor executor = new HiveJobExecutor(cmd, appServer, jobHistoryServer, storageDir);
            executor.setWorkloadId(wid);
            executor.start();
        }
        else{
            JobExecutor executor = new JobExecutor(cmd, appServer, jobHistoryServer, storageDir);
            executor.setWorkloadId(wid);
            executor.start();
        }


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
