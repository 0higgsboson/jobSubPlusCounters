package com.sherpa.core.bl;

import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.util.List;
import java.util.Map;


import com.sherpa.core.dao.PhoenixDAO;
import com.sherpa.core.dao.WorkloadCountersConfigurations;
import com.sherpa.core.dao.WorkloadCountersDAO;
import com.sherpa.core.entitydefinitions.WorkloadCounters;
import org.apache.hadoop.hbase.util.Bytes;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/**
 * Created by akhtar on 22/08/2015.
 */
public class WorkloadCountersManager {
    private static final Logger log = LoggerFactory.getLogger(WorkloadCountersManager.class);

    private WorkloadCountersDAO workloadCountersDAO;
    private PhoenixDAO phoenixDAO;

    public WorkloadCountersManager(){
        workloadCountersDAO = new WorkloadCountersDAO();
        workloadCountersDAO.createTable(WorkloadCountersConfigurations.TABLE_NAME);

        // will be loaded from properties file later
        phoenixDAO = new PhoenixDAO("104.197.42.30");
        phoenixDAO.createCountersTable();
    }


    public void saveCounters(int workloadId, String jobId, Map<String, BigInteger> values) {
        phoenixDAO.saveCounters(workloadId, jobId, values);
    }


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
