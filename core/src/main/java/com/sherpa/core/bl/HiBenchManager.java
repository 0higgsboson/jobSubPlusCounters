package com.sherpa.core.bl;

import com.sherpa.core.dao.HiBenchCountersPhoenixDAO;
import com.sherpa.core.dao.WorkloadCountersConfigurations;
import com.sherpa.core.dao.WorkloadCountersPhoenixDAO;
import com.sherpa.core.entitydefinitions.WorkloadCounters;
import com.sherpa.core.utils.ConfigurationLoader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigInteger;
import java.util.Date;
import java.util.List;
import java.util.Map;


/**
 * Created by akhtar on 22/08/2015.
 */
public class HiBenchManager {
    private static final Logger log = LoggerFactory.getLogger(HiBenchManager.class);

    private HiBenchCountersPhoenixDAO phoenixDAO;
    private HiBenchIdGenerator workloadIdGenerator;

    public HiBenchManager(){
        phoenixDAO = new HiBenchCountersPhoenixDAO(ConfigurationLoader.getPhoenixHost());
        workloadIdGenerator = new HiBenchIdGenerator(phoenixDAO);
        
        // Get unique ID number 
    }


    // For Phoenix
    public void saveCounters(int workloadId, Date date, int executionTime, String jobId, String jobType, Map<String, BigInteger> values, 
    		String config, String sql) {
        phoenixDAO.saveCounters(workloadId, date, executionTime, jobId, jobType, values, config, sql);
    }
    

    public int getFileWorkloadID(String filePath){
        return workloadIdGenerator.getFileWorkloadID(filePath);
    }

    public int getWorkloadIDFromFileContents(String fileContents){
        return workloadIdGenerator.getWorkloadIDFromFileContents(fileContents);
    }



    public int importHiBenchIds(String filePath) {
        return phoenixDAO.importHiBenchIds(filePath);
    }

    public int exportHiBenchIds(String filePath) {
        return  phoenixDAO.exportHiBenchIds(filePath);
    }

    public int exportHiBench(String filePath) {
        return  phoenixDAO.exportHiBench(filePath);
    }


    public int importHiBench(String filePath) {
        return  phoenixDAO.importHiBench(filePath);
    }



    public void close(){
        if(phoenixDAO!=null)
            phoenixDAO.closeConnection();
    }




    }
