package com.sherpa.core.dao;

import com.sherpa.core.entitydefinitions.WorkloadIdDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigInteger;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Created by akhtar on 07/09/2015.
 */
public class WorkloadCountersPhoenixDAO extends  PhoenixDAO{

    private static final Logger log = LoggerFactory.getLogger(WorkloadCountersPhoenixDAO.class);
    
    
    public WorkloadCountersPhoenixDAO(String zookeeper){
        super(zookeeper);

        createTable(WorkloadCountersConfigurations.getCountersTableSchema());
        createTable(WorkloadCountersConfigurations.getWorkloadIdsTableSchema());
    }



    public List<WorkloadIdDto> loadAllWorkloadIds(){
        List<WorkloadIdDto> list = new ArrayList<WorkloadIdDto>();
        ResultSet rset = null;

        String sql = "select * from " + WorkloadCountersConfigurations.WORKLOAD_IDS_TABLE_NAME;
        log.info("Loading Workload ID's ... " + sql);
        Connection con = createConnection();
        PreparedStatement statement = null;
        try {
            statement = con.prepareStatement(sql);
            rset = statement.executeQuery();
            while (rset.next()) {
                WorkloadIdDto dto = new WorkloadIdDto();
                dto.setWorkloadId(rset.getInt("WORKLOAD_ID"));
                dto.setHash(rset.getLong("HASH"));
                dto.setDate(rset.getString("DATE_TIME"));
                list.add(dto);
            }
            statement.close();

            log.info("Found " + list.size() + " Workload ID's");
            System.out.println("Found "  + list.size() + " Workload ID's");
        } catch (SQLException e) {
            e.printStackTrace();
            log.error("SQL: " + sql);
        }

        return list;
    }





    public void addWorkloadId(int workloadId, Date date, long hash){
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
        String date2 = format.format(date);
        String sql = "upsert into " + WorkloadCountersConfigurations.WORKLOAD_IDS_TABLE_NAME +
                " values (" + workloadId + ",'" + date2 + "'," +hash + ")";

        log.info("Adding New Workload ID ... " + sql);
        Connection con = createConnection();
        Statement stmt = null;
        try {
            stmt = con.createStatement();
            stmt.executeUpdate(sql);
            con.commit();
            stmt.close();
            log.info("New Workload ID Added: ..." + workloadId);
            System.out.println("New Workload ID Added: ..." + workloadId);
        } catch (SQLException e) {
            e.printStackTrace();
            log.error("SQL: " + sql);
        }

    }


    public void saveCounters(int workloadId, Date date, int executionTime, String jobId, String jobType, Map<String, BigInteger> values, String query, String sherpaParams){
       
    	SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
        String date2 = format.format(date);
        
        String sql = "upsert into " + WorkloadCountersConfigurations.COUNTERS_TABLE_NAME +
                " values (" + workloadId + ",'" + date2 + "','" +jobId + "'," + executionTime + ",'" + jobType + "',";
        
        String tok[];

        String[] columnNames = WorkloadCountersConfigurations.columnNamesTypesList;
        for(int i=0; i< columnNames.length; i++){
            tok = columnNames[i].split(":");
            if(values.containsKey(tok[0]))
                sql +=  values.get(tok[0]).toString() + ",";
            else
                sql +=  "0" + ",";
        }
       
        sql = sql.substring(0, sql.length()-1) + ")";

        log.info("Saving Record ... " + sql);
        
        Connection con = createConnection();
        Statement stmt = null;
        try {
            stmt = con.createStatement();
            stmt.executeUpdate(sql );
            con.commit();
            stmt.close();
            log.info("Record Saved ...");
            System.out.println("Record Saved ...");
        } catch (SQLException e) {
            e.printStackTrace();
            log.error("SQL: " + sql);
        }

    }





}
