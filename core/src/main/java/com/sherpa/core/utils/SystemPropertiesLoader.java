package com.sherpa.core.utils;

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
    private static final String PROPERTIES_FILE_NAME= "sherpa.properties";
    private static final String PROPERTIES_FILE_PATH= "/opt/";

    private static Properties prop = null;


    private static void loadSystemProperties(){
        prop = new Properties();
        try {
            loadSystemPropertiesFromDefinedPath();
            if(prop==null || prop.size()==0) {
                log.info("No properties found at defined path ...");
                log.info("Loading Properties from: " + PROPERTIES_FILE_NAME);
                ClassLoader classloader = Thread.currentThread().getContextClassLoader();
                InputStream inputStream = classloader.getResourceAsStream(PROPERTIES_FILE_NAME);
                prop.load(inputStream);
                log.info("System Properties loaded successfully");
                log.info("Properties: " + prop.toString());
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }



    private static void loadSystemPropertiesFromDefinedPath(){
        prop = new Properties();
        InputStream inputStream = null;
        try {
            String path = PROPERTIES_FILE_PATH + PROPERTIES_FILE_NAME;
            inputStream = new FileInputStream(new File(path));
            log.info("Loading Properties from: " + path);
            prop.load(inputStream);
            log.info("System Properties loaded from defined path ...");
            log.info("Properties: " + prop.toString());
        } catch (FileNotFoundException e) {
          //  e.printStackTrace();
        } catch (IOException e) {
           // e.printStackTrace();
        }
        finally {
            if(inputStream!=null) {
                try {
                    inputStream.close();
                } catch (IOException e) {
                    //e.printStackTrace();
                }
            }
        }
    }



    public static String getProperty(String name){
        if(prop==null)
            loadSystemProperties();

        return prop.getProperty(name);
    }




}
