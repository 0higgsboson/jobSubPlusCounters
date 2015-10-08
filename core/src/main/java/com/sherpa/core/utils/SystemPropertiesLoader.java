package com.sherpa.core.utils;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.util.Properties;

/**
 * Created by akhtar on 11/08/2015.
 */


/**
 * Loads configurations from cluster's environment
 */

public class SystemPropertiesLoader {
    private static final Logger log = LoggerFactory.getLogger(SystemPropertiesLoader.class);
    private static final String PROPERTIES_FILE_NAME="configs.properties";


    private static Properties prop = null;


    private static void loadSystemProperties(){
        prop = new Properties();
        try {
            log.info("Loading Properties from: " + PROPERTIES_FILE_NAME);
            ClassLoader classloader = Thread.currentThread().getContextClassLoader();
            InputStream inputStream = classloader.getResourceAsStream(PROPERTIES_FILE_NAME);
            prop.load(inputStream);
            log.info("System Properties loaded successfully");
            log.info("Properties: " + prop.toString());
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    public static String getProperty(String name){
        if(prop==null)
            loadSystemProperties();

        return prop.getProperty(name);
    }




}
