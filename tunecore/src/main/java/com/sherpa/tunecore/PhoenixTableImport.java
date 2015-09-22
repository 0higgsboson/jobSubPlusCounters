package com.sherpa.tunecore;

import com.sherpa.core.bl.HiBenchManager;
import com.sherpa.core.bl.WorkloadCountersManager;

import java.io.File;

/**
 * Created by akhtar on 21/09/2015.
 */
public class PhoenixTableImport {

    public static void main(String[] args) {
        if (args.length != 1) {
            System.out.println("Error: input dir missing ...");
            System.exit(1);
        }

        String dirPath = args[0];
        if (!dirPath.endsWith(File.separator))
            dirPath = dirPath + File.separator;


        System.out.println("\n\n\nImporting HiBench IDs Table");
        System.out.println("**********************************************************");
        String filePath = dirPath + PhoenixTableExport.HIBENCH_IDS_FILE_NAME;
        HiBenchManager hiBenchManager = new HiBenchManager();
        hiBenchManager.importHiBenchIds(filePath);


        System.out.println("\n\n\nImporting HiBench Table");
        System.out.println("**********************************************************");
        filePath = dirPath + PhoenixTableExport.HIBENCH_FILE_NAME;
        hiBenchManager.importHiBench(filePath);
        hiBenchManager.close();
        System.out.println("Done Importing HiBench");


        System.out.println("\n\n\nImporting WorkloadCounter IDs");
        System.out.println("**********************************************************");
        filePath = dirPath + PhoenixTableExport.WORKLOAD_COUNTERS_IDS_FILE_NAME;
        WorkloadCountersManager workloadCountersManager = new WorkloadCountersManager();
        workloadCountersManager.importWorkloadCountersIds(filePath);


        System.out.println("\n\n\nImporting WorkloadCounter");
        System.out.println("**********************************************************");
        filePath = dirPath + PhoenixTableExport.WORKLOAD_COUNTERS_FILE_NAME;
        workloadCountersManager.importWorkloadCounters(filePath);
        workloadCountersManager.close();
        System.out.println("Done Importing WorkloadCounters");




    }







}
