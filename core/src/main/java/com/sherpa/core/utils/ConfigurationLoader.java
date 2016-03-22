package com.sherpa.core.utils;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Properties;

/**
 * Created by akhtar on 11/08/2015.
 */


/**
 * Loads configurations from cluster's environment
 */

public class ConfigurationLoader {
    private static final Logger log = LoggerFactory.getLogger(ConfigurationLoader.class);

    private static final String MAPREDUCE_CONF_FILE = "etc/hadoop/mapred-site.xml";
    private static final String YARN_CONF_FILE      = "etc/hadoop/yarn-site.xml";
    private static final String HBASE_CONF_FILE      = "conf/hbase-site.xml";


    private static Properties prop = null;

    // Specifies a directory where counters will be saved
    private static final String STORAGE_DIR = "storage.dir";

    // Specifies how frequenty job status should be polled
    private static final String POLL_INTERVAL_KEY = "pollinterval";


    // Job history server url
    private static final String JOB_HISTORY_URL = "mapreduce.jobhistory.webapp.address";
    // Resource Manager url
    private static final String RESOURCE_MANAGER_URL = "yarn.resourcemanager.webapp.address";
    private static final String ZOOKEEPER = "hbase.zookeeper.quorum";
    private static final String ZOOKEEPER_PORT = "hbase.zookeeper.property.clientPort";


    private static final int DEFAULT_POLL_INTERVAL = 10000;

    @Deprecated
    public void loadConfigurations(String propFileName){
        prop = new Properties();
        try {
            log.info("Loading Properties from: " + propFileName);
            prop.load(new FileInputStream(propFileName));
            log.info("Properties loaded successfully");
            log.info("Properties: " + prop.toString());
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    private static void loadDefaultConfigurations(){
        String hadoopHome = System.getenv("HADOOP_HOME");
        if(hadoopHome==null){
            log.error("Error: HADOOP_HOME is not defined ...");
            System.out.println("Error: HADOOP_HOME is not defined ...");
            System.exit(1);
        }

        String hbaseHome = System.getenv("HBASE_HOME");
      /*  if(hbaseHome==null){
            log.error("Error: HBASE_HOME is not defined ...");
            System.out.println("Error: HBASE_HOME is not defined ...");
            System.exit(1);
        }
*/
        if(!hadoopHome.endsWith(File.separator))
            hadoopHome += File.separator;

   /*     if(!hbaseHome.endsWith(File.separator))
            hbaseHome += File.separator;
*/

        log.info("Hadoop Home: " + hadoopHome);
  //      log.info("Hbase Home: " + hbaseHome);
        System.out.println("Hadoop Home: " + hadoopHome);
    //    System.out.println("Hbase Home: " + hbaseHome);

        Configuration conf = new Configuration();
        conf.addResource(new Path(hadoopHome + MAPREDUCE_CONF_FILE));
        conf.addResource(new Path(hadoopHome + YARN_CONF_FILE));
      //  conf.addResource(new Path(hbaseHome + HBASE_CONF_FILE));


        if(conf.get(JOB_HISTORY_URL)==null){
            log.error("Error: Could not find job history url ...");
            System.out.println("Error: Could not find job history url ...");
            System.exit(1);
        }

        if(conf.get(RESOURCE_MANAGER_URL)==null){
            log.error("Error: Could not find resource manager url ...");
            System.out.println("Error: Could not find resource manager url ...");
            System.exit(1);
        }

        /*if(conf.get(ZOOKEEPER)==null){
            log.error("Error: Could not find zookeeper host ...");
            System.out.println("Error: Could not find zookeeper host ...");
            System.exit(1);
        }
*/

        String jobHistoryUrl      =  "http://" + conf.get(JOB_HISTORY_URL) + "/ws/v1/history/mapreduce/jobs";
        String resourceManagerUrl =  "http://" + conf.get(RESOURCE_MANAGER_URL) + "/ws/v1/cluster/apps";
  /*      String zookeeper = conf.get(ZOOKEEPER);
        String zookeeperPort = conf.get(ZOOKEEPER_PORT);
        if(zookeeperPort==null)
            zookeeperPort="2181";
*/

        log.info("Job History Server URL: " + jobHistoryUrl);
        log.info("ResourceManager URL: " + resourceManagerUrl);
  //      log.info("Zookeeper: " + zookeeper+":"+zookeeperPort);

        prop = new Properties();
        prop.put(JOB_HISTORY_URL, jobHistoryUrl);
        prop.put(RESOURCE_MANAGER_URL,resourceManagerUrl);
    //    prop.put(ZOOKEEPER,zookeeper);
    //    prop.put(ZOOKEEPER_PORT,zookeeperPort);
        prop.put(POLL_INTERVAL_KEY, DEFAULT_POLL_INTERVAL);

        System.out.println("Properties: " + prop);
    }





    public static String getJobHistoryUrl(){
        if(prop==null)
            loadDefaultConfigurations();

        return prop.getProperty(JOB_HISTORY_URL);

    }


    public static String getZookeeper(){
        if(prop==null)
            loadDefaultConfigurations();

        System.out.println("Zookeeper: " + prop.getProperty(ZOOKEEPER));
        return prop.getProperty(ZOOKEEPER);

    }


    public static String getPhoenixHost(){
        String isRemoteDW  = SystemPropertiesLoader.getProperty("remote.dw");
        String phoenixHost = SystemPropertiesLoader.getProperty("phoenix.host");
        if( isRemoteDW!=null && phoenixHost!=null && isRemoteDW.equalsIgnoreCase("true") ){
             System.out.println("Using Phoenix Host From Property File: " + phoenixHost);
             return phoenixHost;
        }
        else {
            if (prop == null)
                loadDefaultConfigurations();

            System.out.println("Setting Phoenix Host To Be Same As Zookeeper IP : " + prop.getProperty(ZOOKEEPER));
            System.out.println("Phoenix Host: " + prop.getProperty(ZOOKEEPER));
            return prop.getProperty(ZOOKEEPER);
        }
    }


    public static String getZookeeperPort(){
        if(prop==null)
            loadDefaultConfigurations();

        return prop.getProperty(ZOOKEEPER_PORT);

    }

    public static String getStorageDir(){
        if(prop==null)
            loadDefaultConfigurations();
        return prop.getProperty(STORAGE_DIR);

    }


    public static String getApplicationServerUrl(){
        if(prop==null)
            loadDefaultConfigurations();
        return prop.getProperty(RESOURCE_MANAGER_URL);

    }



    public static int getPollInterval(){
        if(prop==null)
            loadDefaultConfigurations();

        try {
            return Integer.parseInt(prop.getProperty(POLL_INTERVAL_KEY));
        }catch (NumberFormatException e){
            ;
        }

        return 2*1000;
    }



}
