package com.sherpa.importexport;

import com.sherpa.core.bl.HiBenchManager;
import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.utils.EmailUtils;
import com.sherpa.core.utils.SystemPropertiesLoader;

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

        new PhoenixTableImport().run(args[0], args[1]);
    }



    public  void run(String dirPath, String dateTime) {
        int recordsCount = 0;
        Map<String, Integer> stats = new HashMap<String, Integer>();
        String filePath ;

        System.out.println("\n\n\nImporting WorkloadCounter IDs");
        System.out.println("**********************************************************");
        filePath = dirPath + PhoenixTableExport.WORKLOAD_COUNTERS_IDS_FILE_NAME;


        WorkloadCountersManager workloadCountersManager = null;
        if(SystemPropertiesLoader.getProperty("import.host")==null)
            workloadCountersManager = new WorkloadCountersManager();
        else
            workloadCountersManager = new WorkloadCountersManager(SystemPropertiesLoader.getProperty("import.host"));

        recordsCount = workloadCountersManager.importWorkloadCountersIds(filePath);
        stats.put(PhoenixTableExport.COUNTERS_IDS_TABLE_NAME, recordsCount);

        System.out.println("\n\n\nImporting WorkloadCounter");
        System.out.println("**********************************************************");
        filePath = dirPath + PhoenixTableExport.WORKLOAD_COUNTERS_FILE_NAME;
        recordsCount = workloadCountersManager.importWorkloadCounters(filePath);
        stats.put(PhoenixTableExport.COUNTERS_TABLE_NAME, recordsCount);
        workloadCountersManager.close();
        System.out.println("Done Importing WorkloadCounters");

        new EmailUtils().sendEmail(EmailUtils.IMPORT_SUBJECT, "Import", dateTime, stats);
        System.out.println("Import email notification sent");


    }






}
