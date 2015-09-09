package com.sherpa.core.utils;

import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.dao.WorkloadNameToIdMapper;
import com.sherpa.core.entitydefinitions.WorkloadCounters;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

/**
 * Created by akhtar on 22/08/2015.
 */
public class Driver {
    private static final Logger log = LoggerFactory.getLogger(Driver.class);


    public static void main(String[] args){
        if(args==null || args.length==0){
            log.info("Usage: command [args]");
            log.info("List of commands:");

            log.info("print");
            log.info("    Prints data on standard output device");

            log.info("export filePath");
            log.info("    Exports data to a given file");

            log.info("drop");
            log.info("    Drops hbase table & consequently all of its data");

            log.info("testData");
            log.info("    Inserts some test data into hbase");
            return;
        }


        else if(args[0].equalsIgnoreCase("print"))
            printToConsole();

        else if(args[0].equalsIgnoreCase("testData"))
            insertAndSearchTestData();

        else if(args[0].equalsIgnoreCase("export")) {
            if(args.length==1){
                log.info("Error: filePath missing");
                log.info("export filePath");
                log.info("    Exports data to a given file");
                return;
            }
            else
                export(args[1]);
        }

        else if(args[0].equalsIgnoreCase("drop"))
            dropTable();

    }



    public static void dropTable(){
        WorkloadCountersManager mgr = new WorkloadCountersManager();
        mgr.deleteTable();
        log.info("Done droping table ...");

    }

    public static void printToConsole(){
        WorkloadCountersManager mgr = new WorkloadCountersManager();

        List<WorkloadCounters> list = mgr.getAllWorkloadCounters();
        log.info(WorkloadCounters.getHeaders());
        for(WorkloadCounters w: list) {
            log.info( w.toString());
        }
        log.info("Done printing ...");

    }



    public static void export(String path){
        PrintWriter pw = null;
        try {
            File f = new File(path);
            if(f.exists()){
                log.info("Error: File already exists");
                return;
            }
            WorkloadCountersManager mgr = new WorkloadCountersManager();
            pw = new PrintWriter(new FileWriter(path));
            pw.println(WorkloadCounters.getHeaders());

            int i=0;
            List<WorkloadCounters> list = mgr.getAllWorkloadCounters();
            for (WorkloadCounters w : list) {
                pw.println(w.toString());
                i++;
            }
            pw.flush();
            pw.close();
            log.info("Exported " + i + " Records into " + path);
        }catch(Exception e){
            e.printStackTrace();
        }
        log.info("Done exporting ...");
    }


    public static void  insertAndSearchTestData(){
        WorkloadCountersManager mgr = new WorkloadCountersManager();
        WorkloadCounters wc = new WorkloadCounters();

        wc.setCpu("10");
        wc.setMemory("1G");
        wc.setElapsedTime(90);

        mgr.saveWorkloadCounters(1, DateTimeUtils.convertDateTimeStringToTimestamp(DateTimeUtils.getCurrentDateTime()), "job1", wc);



        wc.setCpu("30");
        wc.setMemory("3G");
        wc.setElapsedTime(30);
        mgr.saveWorkloadCounters(2, DateTimeUtils.convertDateTimeStringToTimestamp(DateTimeUtils.getCurrentDateTime()), "job2", wc);


        wc.setCpu("20");
        wc.setMemory("2G");
        wc.setElapsedTime(20);
        mgr.saveWorkloadCounters(1, DateTimeUtils.convertDateTimeStringToTimestamp(DateTimeUtils.getCurrentDateTime()), "job1", wc);


        long ts = DateTimeUtils.convertDateTimeStringToTimestamp(DateTimeUtils.getCurrentDateTime());
        wc.setCpu("40");
        wc.setMemory("4G");
        wc.setElapsedTime(40);
        mgr.saveWorkloadCounters(2, ts, "job2", wc);


        wc.setCpu("50");
        wc.setMemory("5G");
        wc.setElapsedTime(50);
        mgr.saveWorkloadCounters(3, DateTimeUtils.convertDateTimeStringToTimestamp(DateTimeUtils.getCurrentDateTime()), "job3", wc);



        wc = mgr.getWorkloadCounters(2, ts, "job2");
        log.info( "Search For Workload 2: " + wc.toString());

        log.info("Done inserting & testing ...");

    }




}
