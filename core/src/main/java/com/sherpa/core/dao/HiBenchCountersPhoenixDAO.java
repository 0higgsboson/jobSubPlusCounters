package com.sherpa.core.dao;

import com.sherpa.core.entitydefinitions.WorkloadIdDto;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.math.BigInteger;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Date;

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

        String sql = "select * from " + HiBenchCountersConfigurations.HIBENCH_IDS_TABLE_NAME;
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
        String sql = "select max(RECORD_ID) RECORD_ID from " + HiBenchCountersConfigurations.HIBENCH_TABLE_NAME;
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
        String sql = "upsert into " + HiBenchCountersConfigurations.HIBENCH_IDS_TABLE_NAME +
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
        
        StringBuilder sqlB = new StringBuilder("upsert into " + HiBenchCountersConfigurations.HIBENCH_TABLE_NAME +
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








    public int exportHiBench(String filePath){

        ResultSet rset = null;
        PrintWriter writer = null;

        String sql = "select * from " + HiBenchCountersConfigurations.HIBENCH_TABLE_NAME;
        log.info("Loading HiBench table ... " + sql);



        StringBuilder stringBuilder = new StringBuilder();
        List<String> counters = new ArrayList<String>();

        // list of all counters
        Map<String, BigInteger> map = HiBenchCountersConfigurations.getInitialCounterValuesMap();

        // getting counters names
        Iterator<String> iterator = map.keySet().iterator();
        while(iterator.hasNext()){
             counters.add(iterator.next());
        }

        // forming header
        stringBuilder.append("WORKLOAD_ID").append(",").append("DATE_TIME").append(",").append("JOB_ID").append(",").append("EXECUTION_TIME").append(",").append("JOB_TYPE");
        for(String counter: counters)
             stringBuilder.append(",").append(counter);

        stringBuilder.append(",").append("RECORD_ID").append(",").append("QUERY").append(",").append("PARAMETERS");

        Connection con = createConnection();
        PreparedStatement statement = null;


        int count=0;
        try {
            statement = con.prepareStatement(sql);
            rset = statement.executeQuery();
            while (rset.next()) {
                stringBuilder.append("\n");
                stringBuilder.append(rset.getInt("WORKLOAD_ID")).append(",");
                stringBuilder.append(rset.getString("DATE_TIME")).append(",");
                stringBuilder.append(rset.getString("JOB_ID")).append(",");
                stringBuilder.append(rset.getInt("EXECUTION_TIME")).append(",");
                stringBuilder.append(rset.getString("JOB_TYPE"));

                for(String counter: counters)
                    stringBuilder.append(",").append( rset.getString(counter)  );

                stringBuilder.append(",");
                stringBuilder.append(rset.getInt("RECORD_ID")).append(",");
                stringBuilder.append(rset.getString("QUERY")).append(",");
                stringBuilder.append(rset.getString("PARAMETERS"));

                count++;
            }
            writer = new PrintWriter(new FileWriter(filePath));
            writer.println(stringBuilder.toString());
            writer.flush();
            log.info("Exported Records: " + count);
        } catch (Exception e) {
            e.printStackTrace();
            log.error("SQL: " + sql);
        }finally{
            try{
                statement.close();
                rset.close();
                con.close();
                writer.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        log.info("Done Exporting HiBenchIds");
        return count;
    }



    public int importHiBench(String filePath){

        StringBuilder headerBuilder = new StringBuilder();


        BufferedReader reader = null;
        Connection con = createConnection();
        Statement stmt = null;
        int count = 0;

        try {
            stmt = con.createStatement();
            reader = new BufferedReader(new FileReader(filePath));


            // use the header to insert values in the same order
            String line = reader.readLine();
            String headers[] = line.split(",");

            for(String columnName: headers)
                headerBuilder.append(columnName).append(",");

            String header = headerBuilder.substring(0,headerBuilder.length()-1);
            log.info("Header: " + header);

            while( (line=reader.readLine()) != null ){
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.append("upsert into ").append(HiBenchCountersConfigurations.HIBENCH_TABLE_NAME).append(" (").append(header).append(")").append(" values (");

                String[] tok = line.split(",");

                for(int i=0; i<tok.length; i++){
                    //  adding single qoutes for datetime, Job_ID, Job_Type, Query, Parameters columns
                    if(i==1 || i==2 || i==4 || (i==tok.length-2) || (i==tok.length-1) )
                       stringBuilder.append("'").append(tok[i]).append("',");
                    else
                        stringBuilder.append(tok[i]).append(",");
                }

                String sql = stringBuilder.substring(0, stringBuilder.length()-1) + ")";

                stmt.executeUpdate(sql);
                con.commit();
                count++;



            }
            log.info("Imported Records: " + count);

        } catch (Exception e) {
            e.printStackTrace();
        }finally{
            try{
                stmt.close();
                con.close();
                reader.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        log.info("Done Importing HiBenchIds");
        return count;
    }







    public int exportHiBenchIds(String filePath){
        ResultSet rset = null;
        PrintWriter writer = null;

        String sql = "select * from " + HiBenchCountersConfigurations.HIBENCH_IDS_TABLE_NAME;
        log.info("Loading HiBench ID's ... " + sql);

        Connection con = createConnection();
        PreparedStatement statement = null;
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append("WORKLOAD_ID").append(",").append("DATE_TIME").append(",").append("HASH");

        int count=0;
        try {
            statement = con.prepareStatement(sql);
            rset = statement.executeQuery();
            while (rset.next()) {
                stringBuilder.append("\n");
                stringBuilder.append(rset.getInt("WORKLOAD_ID")).append(",");
                stringBuilder.append(rset.getString("DATE_TIME")).append(",");
                stringBuilder.append(rset.getLong("HASH"));
                count++;
            }
            writer = new PrintWriter(new FileWriter(filePath));
            writer.println(stringBuilder.toString());
            writer.flush();
            log.info("Exported Records: " + count);
        } catch (Exception e) {
            e.printStackTrace();
            log.error("SQL: " + sql);
        }finally{
            try{
                statement.close();
                rset.close();
                con.close();
                writer.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        log.info("Done Exporting HiBenchIds");
        return count;
    }



    public int importHiBenchIds(String filePath){
        BufferedReader reader = null;
        Connection con = createConnection();
        Statement stmt = null;
        int count = 0;

        try {
            stmt = con.createStatement();
            reader = new BufferedReader(new FileReader(filePath));

            // ignore the header
            String line = reader.readLine();

            while( (line=reader.readLine()) != null ){
                String[] tok = line.split(",");
                if(tok.length !=3 )
                    continue;
                String sql = "upsert into " + HiBenchCountersConfigurations.HIBENCH_IDS_TABLE_NAME +
                        " values (" + tok[0] + ",'" + tok[1] + "'," + tok[2] + ")";

                stmt.executeUpdate(sql);
                con.commit();
                count++;
            }
            log.info("Imported Records: " + count);

        } catch (Exception e) {
            e.printStackTrace();
        }finally{
            try{
                stmt.close();
                con.close();
                reader.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        log.info("Done Importing HiBenchIds");
        return  count;
    }








}
