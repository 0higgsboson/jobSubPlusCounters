package com.sherpa.tunecore.joblauncher;

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
 * Loads configurations from a property's file
 */

public class ConfigurationLoader {
    private static final Logger log = LoggerFactory.getLogger(ConfigurationLoader.class);

    private static final String MAPREDUCE_CONF_FILE = "etc/hadoop/mapred-site.xml";
    private static final String YARN_CONF_FILE      = "etc/hadoop/yarn-site.xml";



    private static Properties prop = null;
    // Job history server url
    private static final String JOB_HISTORY_URL = "jobhistory.url";
    // Specifies a directory where counters will be saved
    private static final String STORAGE_DIR = "storage.dir";
    // Resource Manager url
    private static final String RESOURCE_MANAGER_URL = "appserver.url";
    // Specifies how frequenty job status should be polled
    private static final String POLL_INTERVAL_KEY = "pollinterval";

    private static final int DEFAULT_POLL_INTERVAL = 5000;

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


    public void loadDefaultConfigurations(){
        String hadoopHome = System.getenv("HADOOP_HOME");
        if(hadoopHome==null){
            log.error("Error: HADOOP_HOME is not defined ...");
            System.exit(1);
        }
        if(!hadoopHome.endsWith(File.separator))
            hadoopHome = File.separator;

        log.info("Hadoop Home: " + hadoopHome);
        Configuration conf = new Configuration();
        conf.addResource(new Path(hadoopHome + MAPREDUCE_CONF_FILE));
        conf.addResource(new Path(hadoopHome + YARN_CONF_FILE));

        String jobHistoryUrl      =  "http://" + conf.get("mapreduce.jobhistory.webapp.address") + "/ws/v1/history/mapreduce/jobs";
        String resourceManagerUrl =  "http://" + conf.get("yarn.resourcemanager.webapp.address") + "/ws/v1/cluster/apps";

        log.info("Job History Server URL: " + jobHistoryUrl);
        log.info("ResourceManager URL: " + resourceManagerUrl);

        prop = new Properties();
        prop.put(JOB_HISTORY_URL, jobHistoryUrl);
        prop.put(RESOURCE_MANAGER_URL,resourceManagerUrl);
        prop.put(POLL_INTERVAL_KEY, DEFAULT_POLL_INTERVAL);

    }





    public String getJobHistoryUrl(){
        if(prop!=null)
            return prop.getProperty(JOB_HISTORY_URL);

        return "";
    }


    public String getStorageDir(){
        if(prop!=null)
            return prop.getProperty(STORAGE_DIR);

        return "";
    }


    public String getApplicationServerUrl(){
        if(prop!=null)
            return prop.getProperty(RESOURCE_MANAGER_URL);

        return "";
    }



    public int getPollInterval(){
        if(prop!=null) {
            try {
                return Integer.parseInt(prop.getProperty(POLL_INTERVAL_KEY));
            }catch (NumberFormatException e){
                ;
            }
        }
        return 5*1000;  // defaults to 5 sec
    }



}
