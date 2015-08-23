package com.sherpa.tunecore.joblauncher;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

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


    private Properties prop = null;
    // Job history server url
    private static final String JOB_HISTORY_URL = "jobhistory.url";
    // Specifies a directory where counters will be saved
    private static final String STORAGE_DIR = "storage.dir";
    // Resource Manager url
    private static final String APPLICATION_SERVER_URL = "appserver.url";
    // Specifies how frequenty job status should be polled
    private static final String POLL_INTERVAL = "pollinterval";

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
            return prop.getProperty(APPLICATION_SERVER_URL);

        return "";
    }



    public int getPollInterval(){
        if(prop!=null) {
            try {
                return Integer.parseInt(prop.getProperty(POLL_INTERVAL));
            }catch (NumberFormatException e){
                ;
            }
        }
        return 5*1000;  // defaults to 5 sec
    }



}
