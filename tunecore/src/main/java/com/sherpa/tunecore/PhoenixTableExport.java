package com.sherpa.tunecore;

import com.sherpa.core.bl.HiBenchManager;
import com.sherpa.core.bl.WorkloadCountersManager;

import java.io.File;

/**
 * Created by akhtar on 21/09/2015.
 */
public class PhoenixTableExport {
    public static final String HIBENCH_IDS_FILE_NAME="HiBench_Ids.csv";
    public static final String HIBENCH_FILE_NAME="HiBench.csv";

    public static final String WORKLOAD_COUNTERS_IDS_FILE_NAME="WorkloadCounters_Ids.csv";
    public static final String WORKLOAD_COUNTERS_FILE_NAME="WorkloadCounters.csv";



    public static void main(String[] args){
        if(args.length!=1){
            System.out.println("Error: output dir missing ...");
            System.exit(1);
        }

        String dirPath = args[0];
        if(!dirPath.endsWith(File.separator))
            dirPath = dirPath + File.separator;

        File file = new File(dirPath);
        if(!file.exists()){
            file.mkdirs();
            System.out.println("Created output dir ...");
        }


        System.out.println("\n\n\nExporting HiBench IDs");
        System.out.println("**********************************************************");
        String filePath = dirPath + HIBENCH_IDS_FILE_NAME;
        HiBenchManager hiBenchManager = new HiBenchManager();
        hiBenchManager.exportHiBenchIds(filePath);


        System.out.println("\n\n\nExporting HiBench");
        System.out.println("**********************************************************");
        filePath = dirPath + HIBENCH_FILE_NAME;
        hiBenchManager.exportHiBench(filePath);
        hiBenchManager.close();
        System.out.println("Done Exporting HiBench");


        System.out.println("\n\n\nExporting WorkloadCounters IDs");
        System.out.println("**********************************************************");
        filePath = dirPath + WORKLOAD_COUNTERS_IDS_FILE_NAME;
        WorkloadCountersManager workloadCountersManager = new WorkloadCountersManager();
        workloadCountersManager.exportWorkloadCountersIds(filePath);


        System.out.println("\n\n\nExporting WorkloadCounters");
        System.out.println("**********************************************************");
        filePath = dirPath + WORKLOAD_COUNTERS_FILE_NAME;
        workloadCountersManager.exportWorkloadCounters(filePath);
        workloadCountersManager.close();
        System.out.println("Done Exporting WorkloadCounters");

    }












}
