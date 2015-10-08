package com.sherpa.tunecore;

import com.sherpa.core.bl.HiBenchManager;
import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.utils.EmailUtils;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by akhtar on 21/09/2015.
 */
public class PhoenixTableImport {

    public static void main(String[] args) {
        if (args.length != 2) {
            System.out.println("Usage: inputDirName dateTime");
            System.exit(1);
        }

        String dirPath = args[0];
        if (!dirPath.endsWith(File.separator))
            dirPath = dirPath + File.separator;

        int recordsCount = 0;
        Map<String, Integer> stats = new HashMap<String, Integer>();

        System.out.println("\n\n\nImporting HiBench IDs Table");
        System.out.println("**********************************************************");
        String filePath = dirPath + PhoenixTableExport.HIBENCH_IDS_FILE_NAME;
        HiBenchManager hiBenchManager = new HiBenchManager();
        recordsCount = hiBenchManager.importHiBenchIds(filePath);
        stats.put(PhoenixTableExport.HIBENCH_IDS_TABLE_NAME, recordsCount);

        System.out.println("\n\n\nImporting HiBench Table");
        System.out.println("**********************************************************");
        filePath = dirPath + PhoenixTableExport.HIBENCH_FILE_NAME;
        recordsCount = hiBenchManager.importHiBench(filePath);
        stats.put(PhoenixTableExport.HIBENCH_TABLE_NAME, recordsCount);
        hiBenchManager.close();
        System.out.println("Done Importing HiBench");


        System.out.println("\n\n\nImporting WorkloadCounter IDs");
        System.out.println("**********************************************************");
        filePath = dirPath + PhoenixTableExport.WORKLOAD_COUNTERS_IDS_FILE_NAME;
        WorkloadCountersManager workloadCountersManager = new WorkloadCountersManager();
        recordsCount = workloadCountersManager.importWorkloadCountersIds(filePath);
        stats.put(PhoenixTableExport.COUNTERS_IDS_TABLE_NAME, recordsCount);

        System.out.println("\n\n\nImporting WorkloadCounter");
        System.out.println("**********************************************************");
        filePath = dirPath + PhoenixTableExport.WORKLOAD_COUNTERS_FILE_NAME;
        recordsCount = workloadCountersManager.importWorkloadCounters(filePath);
        stats.put(PhoenixTableExport.COUNTERS_TABLE_NAME, recordsCount);
        workloadCountersManager.close();
        System.out.println("Done Importing WorkloadCounters");

        new EmailUtils().sendEmail(EmailUtils.IMPORT_SUBJECT, "Import", args[1], stats);
        System.out.println("Import email notification sent");


    }







}
