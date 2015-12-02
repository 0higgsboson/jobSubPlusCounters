package com.sherpa.tunecore.joblauncher;

/**
 * Created by akhtar on 11/08/2015.
 */

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *  Class to externalize URL creation
 *  Follows API doc 2.6
 *  https://hadoop.apache.org/docs/r2.6.0/hadoop-mapreduce-client/hadoop-mapreduce-client-hs/HistoryServerRest.html
 *
 */
public class SPI {

    private static final Logger log = LoggerFactory.getLogger(SPI.class);


    public static String getJobUri(String jobHistoryUrl, String jobId){
        if(!jobHistoryUrl.endsWith("/"))
            jobHistoryUrl += "/";

        String url = jobHistoryUrl + jobId;
        log.info("SPI getJobUri URL: " + url);
        return url;
    }

    public static String getJobConfUri(String jobHistoryUrl, String jobId){
        if(!jobHistoryUrl.endsWith("/"))
            jobHistoryUrl += "/";

        String url = jobHistoryUrl + jobId + "/conf";
        log.info("SPI getJobConfUri URL: " + url);
        return url;
    }


    public static String getJobTaskUri(String jobHistoryUrl, String jobId){
        if(!jobHistoryUrl.endsWith("/"))
            jobHistoryUrl += "/";

        String url = jobHistoryUrl + jobId + "/tasks";
        log.info("SPI getJobTaskUri URL: " + url);
        return url;
    }


    public static String getJobTaskCounterUri(String jobHistoryUrl, String jobId, String taskId){
        if(!jobHistoryUrl.endsWith("/"))
            jobHistoryUrl += "/";

        String url = jobHistoryUrl + jobId + "/tasks/" + taskId + "/counters";
        log.info("SPI getJobTaskCounterUri URL: " + url);
        return url;
    }



    public static String getJobCountersUri(String jobHistoryUrl, String jobId){
        if(!jobHistoryUrl.endsWith("/"))
            jobHistoryUrl += "/";

        String url = jobHistoryUrl + jobId + "/counters";
        log.info("SPI getJobCountersUri URL: " + url);
        return url;
    }









}
