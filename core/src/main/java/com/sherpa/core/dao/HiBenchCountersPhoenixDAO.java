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
public class HiBenchCountersPhoenixDAO extends  PhoenixDAO{

    private static final Logger log = LoggerFactory.getLogger(HiBenchCountersPhoenixDAO.class);


    public HiBenchCountersPhoenixDAO(String zookeeper){
        super(zookeeper);

        createTable(HiBenchCountersConfigurations.getCountersTableSchema());
        createTable(HiBenchCountersConfigurations.getWorkloadIdsTableSchema());
    }


    public List<WorkloadIdDto> loadAllWorkloadIds(){
        List<WorkloadIdDto> list = new ArrayList<WorkloadIdDto>();
        ResultSet rset = null;

        String sql = "select * from " + HiBenchCountersConfigurations.WORKLOAD_IDS_TABLE_NAME;
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

            log.info("Found " + list.size() + " Workload ID's");
            
        } catch (SQLException e) {
            e.printStackTrace();
            log.error("SQL: " + sql);
        }finally{
        	try{
        		statement.close();
        		rset.close();
        		con.close();
        	}catch(Exception e){
        		e.printStackTrace();
        	}
        }

        return list;
    }
    
    public int getMaxIdPlusOneForCounterTable(){
    	ResultSet rset = null;
    	
    	int curr = 0;
        String sql = "select max(RECORD_ID) RECORD_ID from " + HiBenchCountersConfigurations.COUNTERS_TABLE_NAME;
        log.info("Getting a max id number... ");
       
        Connection con = createConnection();
        Statement stmt = null;
        try {
            stmt = con.createStatement();
            rset = stmt.executeQuery(sql);
            
            while (rset.next()) {
            	curr = rset.getInt("RECORD_ID");
            }
            log.info("Current max record count: "+curr);
           
            return curr+=1;
            
        }catch(Exception e){
        	log.error("Failed to query database for max counter seq number: "+e);
        }finally{
        	try{
        		stmt.close();
        		rset.close();
        		con.close();
        	}catch(Exception e){
        		e.printStackTrace();
        	}
        }
        return curr;
    }


    public void addWorkloadId(int workloadId, Date date, long hash){
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
        String date2 = format.format(date);
        String sql = "upsert into " + HiBenchCountersConfigurations.WORKLOAD_IDS_TABLE_NAME +
                " values (" + workloadId + ",'" + date2 + "'," +hash + ")";

        log.info("Adding New Workload ID ... " + sql);
        Connection con = createConnection();
        Statement stmt = null;
        try {
            stmt = con.createStatement();
            stmt.executeUpdate(sql);
            con.commit();
            
            log.info("New Workload ID Added: ..." + workloadId);
           
        } catch (SQLException e) {
            e.printStackTrace();
            log.error("SQL: " + sql);
        }finally{
        	try{
        		stmt.close();
        		con.close();
        	}catch(Exception e){
        		e.printStackTrace();
        	}
        }

    }


    public void saveCounters(int workloadId, Date date, int executionTime, String jobId, String jobType, Map<String, BigInteger> values,
    		String config, String hivesql){
    	
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
        String sql;
        
        StringBuilder sqlB = new StringBuilder("upsert into " + HiBenchCountersConfigurations.COUNTERS_TABLE_NAME +
                " values (" + workloadId + ",'" + format.format(date) + "','" +jobId + "'," + executionTime + ",'" + jobType + "',");
        
        String tok[];

        String[] columnNames = HiBenchCountersConfigurations.columnNamesTypesList;
        for(int i=0; i< columnNames.length; i++){
            tok = columnNames[i].split(":");
            if(values.containsKey(tok[0]))
                sqlB.append(values.get(tok[0]).toString() + ",");
            else
            	sqlB.append("0").append(",");
        }
        // New columns to add:: RECORD_ID, QUERY, PARAMETERS
        //sqlB.append("0").append(",");// RECORD_ID defaulted to zero for now
        sqlB.append(getMaxIdPlusOneForCounterTable()).append(",");
        sqlB.append("'"+"NA"+"'").append(",");
        sqlB.append("'"+config+"'").append(",");
        		
        sql = sqlB.toString();
        
        sql = sql.substring(0, sql.length()-1) + ")";

        log.info("Saving Record ... " + sql);
        Connection con = createConnection();
        Statement stmt = null;
        try {
            stmt = con.createStatement();
            stmt.executeUpdate(sql );
            con.commit();
            
            log.info("Record Saved ...");
        } catch (SQLException e) {
            e.printStackTrace();
            log.error("SQL: " + sql);
        }finally{
        	try{
        		stmt.close();
        		con.close();
        	}catch(Exception e){
        		e.printStackTrace();
        	}
        	
        }

    }





}
