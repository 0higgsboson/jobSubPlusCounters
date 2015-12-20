package com.sherpa.importexport;

import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.utils.EmailUtils;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by akhtar on 21/09/2015.
 */
public class PhoenixTableExport {
    public static final String HIBENCH_IDS_FILE_NAME="HiBench_Ids.csv";
    public static final String HIBENCH_FILE_NAME="HiBench.csv";

    public static final String WORKLOAD_COUNTERS_IDS_FILE_NAME="WorkloadCounters_Ids.csv";
    public static final String WORKLOAD_COUNTERS_FILE_NAME="WorkloadCounters.csv";


    public static final String HIBENCH_TABLE_NAME="HiBench";
    public static final String HIBENCH_IDS_TABLE_NAME="HiBenchids";
    public static final String COUNTERS_TABLE_NAME="Counters";
    public static final String COUNTERS_IDS_TABLE_NAME="WorkloadIds";


    public static void main(String[] args){

        if(args.length!=2){
            System.out.println("Usage: outputDirName dateTime");
            System.exit(1);
        }

        new PhoenixTableExport().run(args[0], args[1]);
    }



    public String run(String path, String dateTime){
        String dirPath = path;
        if(!dirPath.endsWith(File.separator))
            dirPath = dirPath + File.separator ;

        dirPath +=  "Export" + File.separator;

        File file = new File(dirPath);
        if(!file.exists()){
            file.mkdirs();
            System.out.println("Created output dir ..." + dirPath);
        }

        Map<String, Integer> stats = new HashMap<String, Integer>();

        int recordsCount = 0;
        String filePath;
        WorkloadCountersManager workloadCountersManager = new WorkloadCountersManager();

        /*
        System.out.println("\n\n\nExporting WorkloadCounters IDs");
        System.out.println("**********************************************************");
        filePath = dirPath + WORKLOAD_COUNTERS_IDS_FILE_NAME;
        recordsCount = workloadCountersManager.exportWorkloadCountersIds(filePath);
        stats.put(COUNTERS_IDS_TABLE_NAME, recordsCount);
*/
        System.out.println("\n\n\nExporting WorkloadCounters");
        System.out.println("**********************************************************");
        filePath = dirPath + WORKLOAD_COUNTERS_FILE_NAME;
        recordsCount = workloadCountersManager.exportWorkloadCounters(filePath);
        stats.put(COUNTERS_TABLE_NAME, recordsCount);
        workloadCountersManager.close();
        System.out.println("Done Exporting WorkloadCounters");

        new EmailUtils().sendEmail(EmailUtils.EXPORT_SUBJECT, "Export", dateTime, stats);
        System.out.println("Export email notification sent");

        return dirPath;
    }










}
