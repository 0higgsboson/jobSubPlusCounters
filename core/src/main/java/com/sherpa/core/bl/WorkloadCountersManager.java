package com.sherpa.core.bl;

import java.math.BigInteger;
import java.util.Date;
import java.util.List;
import java.util.Map;


import com.sherpa.core.dao.PhoenixDAO;
import com.sherpa.core.dao.WorkloadCountersConfigurations;
import com.sherpa.core.dao.WorkloadCountersHbaseDAO;
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

    private WorkloadCountersHbaseDAO workloadCountersDAO;
    private WorkloadCountersPhoenixDAO phoenixDAO;
    private WorkloadIdGenerator workloadIdGenerator;

    public WorkloadCountersManager(){
        workloadCountersDAO = new WorkloadCountersHbaseDAO();
        workloadCountersDAO.createTable(WorkloadCountersConfigurations.TABLE_NAME);


        phoenixDAO = new WorkloadCountersPhoenixDAO(ConfigurationLoader.getZookeeper());
        workloadIdGenerator = new WorkloadIdGenerator(phoenixDAO);
    }



    // For Phoenix
    public void saveCounters(int workloadId, Date date, int executionTime, String jobId, String jobType, Map<String, BigInteger> values) {
        phoenixDAO.saveCounters(workloadId, date, executionTime, jobId, jobType, values);
    }


    public int getFileWorkloadID(String filePath){
        return workloadIdGenerator.getFileWorkloadID(filePath);
    }

    public int getWorkloadIDFromFileContents(String fileContents){
        return workloadIdGenerator.getWorkloadIDFromFileContents(fileContents);
    }




    // For Hbase

    public void deleteTable(){
        workloadCountersDAO.deleteTable(WorkloadCountersConfigurations.TABLE_NAME);
    }


    public void saveWorkloadCounters(int wid, long ts, String jobId, WorkloadCounters workloadCounters)  {
        workloadCountersDAO.saveWorkloadCounters(WorkloadCountersConfigurations.TABLE_NAME, workloadCountersDAO.getWorkloadCounterRowKey(wid, ts, jobId), workloadCounters);
    }


    public WorkloadCounters getWorkloadCounters(int wid, long ts, String jobId)  {
        return workloadCountersDAO.getWorkloadCounters(WorkloadCountersConfigurations.TABLE_NAME, workloadCountersDAO.getWorkloadCounterRowKey(wid, ts, jobId));
    }


    public WorkloadCounters getWorkloadCounters(int wid, long ts)  {
        return workloadCountersDAO.getWorkloadCounters(WorkloadCountersConfigurations.TABLE_NAME, workloadCountersDAO.getWorkloadCounterRowKey(wid, ts, ""));
    }


    public WorkloadCounters getWorkloadCounters(int wid)  {
        return workloadCountersDAO.getWorkloadCounters(WorkloadCountersConfigurations.TABLE_NAME, workloadCountersDAO.getWorkloadCounterRowKey(wid, 0, ""));
    }


    public List<WorkloadCounters> getAllWorkloadCounters(){
        return workloadCountersDAO.getAllWorkloadCounters(WorkloadCountersConfigurations.TABLE_NAME);
    }



    public void close(){
        if(phoenixDAO!=null)
            phoenixDAO.closeConnection();
    }




    }
