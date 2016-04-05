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

    public static int getIntProperty(String name){
        int val=-1;
        if(prop==null)
            loadSystemProperties();
        if(prop.containsKey(name)){
            try {
                val = Integer.parseInt(prop.getProperty(name));
            }catch (NumberFormatException e){

            }
        }
        return val;
    }


    public static int getMapHeapSize(){
        int size= getIntProperty("java.heap.size.map");
        if(size <= 0)
            size = 75;

        return size;
    }

    public static int getReduceHeapSize(){
        int size=getIntProperty("java.heap.size.reduce");
        if(size <= 0)
            size = 75;
        return size;
    }

    public static String getClientAgentHostname(){
        String host=  getProperty("client.agent.hostname");
        if(host==null)
            host = "localhost";

        return host;
    }


    public static String getTenzingHostname(){
        String host=  getProperty("tenzing.hostname");
        if(host==null)
            host = "localhost";

        return host;
    }


    public static String getMongoDbHostname(){
        String host=  getProperty("db.mongo.host");
        if(host==null){
            System.out.println("Mongo DB host property not found, using localhost as default ...");
            host = "localhost";
        }

        return host;
    }


    public static int getMongoDbPort(){
        int port=getIntProperty("db.mongo.port");
        if(port <= 0) {
            System.out.println("Mongo DB port property not found, using 27017 as default ...");
            port = 27017;
        }
        return port;
    }


    public static String getHadoopVersion(){
        String hadoopVersion=  getProperty("hadoop.version");
        if(hadoopVersion==null){
            System.out.println("Hadoop version property not found, using 2.6.0 as default ...");
            hadoopVersion = "2.6.0";
        }

        return hadoopVersion;
    }


    public static String getHistoryServerMongoDbHostname(){
        String host=  getProperty("historyserver.db.mongo.host");
        if(host==null){
            System.out.println("HistoryServer Mongo DB host property not found, using localhost as default ...");
            host = "localhost";
        }

        return host;
    }


    public static int getHistoryServerMongoDbPort(){
        int port=getIntProperty("historyserver.db.mongo.port");
        if(port <= 0) {
            System.out.println("HistoryServer Mongo DB port property not found, using 27017 as default ...");
            port = 27017;
        }
        return port;
    }








}
