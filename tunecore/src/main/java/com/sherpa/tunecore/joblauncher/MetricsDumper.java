package com.sherpa.tunecore.joblauncher;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.UUID;

/**
 * Created by akhtar on 10/08/2015.
 */


/**
 *  Saves counters data in a file
 */
public class MetricsDumper {
    private static final Logger log = LoggerFactory.getLogger(MetricsDumper.class);


    // utility method for random names
    private  String getFileName(){
        return UUID.randomUUID().toString() + ".json";
    }

    // File name generation utility method
    private  String getFileName(String prefix, String jobId){
        return prefix + "_" + jobId + ".json";
    }


    // Saves json data in a file
    // File name is formed from a prefix and job ID
    public String dumpToFile(String prefix, String jobId, String dir, String data){
        PrintWriter printWriter = null;
        if(!dir.endsWith("/"))
            dir += "/";

        File file = new File(dir);
        if(!file.exists())
            file.mkdir();

        String filePath = dir  + getFileName(prefix, jobId);
        log.info("Saving data to: " + filePath);

        try{
            printWriter = new PrintWriter(new FileWriter(new File(filePath)));
            printWriter.println(data);
            printWriter.flush();

        }
        catch (IOException e){
            e.printStackTrace();
        }
        finally {
            printWriter.close();
        }


        return filePath;
    }





}
