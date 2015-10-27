package com.sherpa.core.bl;

import java.math.BigInteger;
import java.util.Date;
import java.util.List;
import java.util.Map;


import com.sherpa.core.dao.PhoenixDAO;
import com.sherpa.core.dao.WorkloadCountersConfigurations;
import com.sherpa.core.dao.WorkloadCountersPhoenixDAO;
import com.sherpa.core.entitydefinitions.WorkloadCounters;
import com.sherpa.core.utils.ConfigurationLoader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/**
 * Created by akhtar on 22/08/2015.
 */
public class WorkloadCountersManager {
    private static final Logger log = LoggerFactory.getLogger(WorkloadCountersManager.class);

    private WorkloadCountersPhoenixDAO phoenixDAO;
    private WorkloadIdGenerator workloadIdGenerator;

    public WorkloadCountersManager(){
        phoenixDAO = new WorkloadCountersPhoenixDAO(ConfigurationLoader.getZookeeper());
        workloadIdGenerator = new WorkloadIdGenerator(phoenixDAO);
    }


    // For Phoenix
    public void saveCounters(int workloadId, int executionTime, Map<String, BigInteger> counters, Map<String, String> configurations){
        phoenixDAO.saveCounters(workloadId, executionTime, counters, configurations);
    }


    public int getFileWorkloadID(String filePath){
        return workloadIdGenerator.getFileWorkloadID(filePath);
    }

    public int getWorkloadIDFromFileContents(String fileContents){
        return workloadIdGenerator.getWorkloadIDFromFileContents(fileContents);
    }


    public int importWorkloadCountersIds(String filePath) {
        return phoenixDAO.importWorkloadCountersIds(filePath);
    }

    public int exportWorkloadCountersIds(String filePath) {
        return phoenixDAO.exportWorkloadCountersIds(filePath);
    }

    public int exportWorkloadCounters(String filePath) {
        return phoenixDAO.exportWorkloadCounters(filePath);
    }


    public int importWorkloadCounters(String filePath) {
        return phoenixDAO.importWorkloadCounters(filePath);
    }






    public void close(){
        if(phoenixDAO!=null)
            phoenixDAO.closeConnection();
    }




    }
