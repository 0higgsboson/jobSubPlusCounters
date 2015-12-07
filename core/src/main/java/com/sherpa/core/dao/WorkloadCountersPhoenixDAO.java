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
    
    public void saveCounters(String workloadId, int executionTime, Map<String, BigInteger> counters, Map<String, String> configurations){

        StringBuilder header = new StringBuilder();
        StringBuilder values = new StringBuilder();
        StringBuilder sql    = new StringBuilder();

        sql.append("upsert into " + WorkloadCountersConfigurations.COUNTERS_TABLE_NAME + " ( '");

        header.append(WorkloadCountersConfigurations.COLUMN_WORKLOAD_ID).append("',").append(WorkloadCountersConfigurations.COLUMN_EXECUTION_TIME);
        values.append(workloadId).append(",").append(executionTime);

        for(Map.Entry<String,String> e:  configurations.entrySet()){
            header.append(",").append(e.getKey());
            values.append(",'").append(e.getValue()).append("'");
        }

        for(Map.Entry<String,BigInteger> e:  counters.entrySet()){
            header.append(",").append(e.getKey());
            values.append(",").append(e.getValue());
        }

        sql.append(header.toString()).append(" ) ").append("values (").append(values.toString()).append(")");
        //log.info("Saving Record ... " + sql);
        
        Connection con = createConnection();
        Statement stmt = null;
        try {
            stmt = con.createStatement();
            stmt.executeUpdate(sql.toString() );
            con.commit();
            stmt.close();
            log.info("Record Saved ...");
            System.out.println("Record Saved ...");
        } catch (SQLException e) {
            e.printStackTrace();
            log.error("SQL: " + sql);
            System.out.println(e.getMessage());
            System.out.println("Error SQL: " + sql);
        }

    }


    public void saveCounters(int workloadId, int executionTime, Map<String, BigInteger> counters, Map<String, String> configurations){

        StringBuilder header = new StringBuilder();
        StringBuilder values = new StringBuilder();
        StringBuilder sql    = new StringBuilder();

        sql.append("upsert into " + WorkloadCountersConfigurations.COUNTERS_TABLE_NAME + " ( ");

        header.append(WorkloadCountersConfigurations.COLUMN_WORKLOAD_ID).append(",").append(WorkloadCountersConfigurations.COLUMN_EXECUTION_TIME);
        values.append(workloadId).append(",").append(executionTime);

        for(Map.Entry<String,String> e:  configurations.entrySet()){
            header.append(",").append(e.getKey());
            values.append(",'").append(e.getValue()).append("'");
        }

        for(Map.Entry<String,BigInteger> e:  counters.entrySet()){
            header.append(",").append(e.getKey());
            values.append(",").append(e.getValue());
        }

        sql.append(header.toString()).append(" ) ").append("values (").append(values.toString()).append(")");
        //log.info("Saving Record ... " + sql);

        Connection con = createConnection();
        Statement stmt = null;
        try {
            stmt = con.createStatement();
            stmt.executeUpdate(sql.toString() );
            con.commit();
            stmt.close();
            log.info("Record Saved ...");
            System.out.println("Record Saved ...");
        } catch (SQLException e) {
            e.printStackTrace();
            log.error("SQL: " + sql);
            System.out.println(e.getMessage());
            System.out.println("Error SQL: " + sql);
        }

    }





    public int exportWorkloadCounters(String filePath){

        ResultSet rset = null;
        PrintWriter writer = null;

        String sql = "select * from " + WorkloadCountersConfigurations.COUNTERS_TABLE_NAME;
        log.info("Loading WorkloadCounters table ... " + sql);



        StringBuilder stringBuilder = new StringBuilder();
        List<String> columnNames = WorkloadCountersConfigurations.getColumnNames();

        boolean isFirstAppend = true;
        for(String s: columnNames){
            if(isFirstAppend){
                stringBuilder.append(s);
                isFirstAppend=false;
            }
            else
                stringBuilder.append(",").append(s);

        }

        Connection con = createConnection();
        PreparedStatement statement = null;

        int count=0;
        try {
            statement = con.prepareStatement(sql);
            rset = statement.executeQuery();
            while (rset.next()) {
                stringBuilder.append("\n");

                isFirstAppend = true;
                for(String colName: columnNames){
                    if(!isFirstAppend)
                        stringBuilder.append(",");

                    if(colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_WORKLOAD_ID) || colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_EXECUTION_TIME))
                        stringBuilder.append(rset.getInt(colName));

                    else if(colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_JOB_ID) || colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_JOB_URL) ||
                            colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_START_TIME) || colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_END_TIME) ||
                            colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_COUNTERS) || colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_CONFIGURATIONS) ||
                            colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_COMPUTE_ENGINE_TYPE)   ) {
                        stringBuilder.append(rset.getString(colName));
                    }
                    else
                        stringBuilder.append(rset.getString(colName));

                    isFirstAppend = false;
                }

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

        log.info("Done Exporting WorkloadCounters");
        return  count;
    }



    public int importWorkloadCounters(String filePath){

        StringBuilder headerBuilder = new StringBuilder();


        BufferedReader reader = null;
        Connection con = createConnection();
        Statement stmt = null;
        int count = 0;
        int errors = 0;

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

            String[] headerTok = header.split(",");
            while( (line=reader.readLine()) != null ){
                StringBuilder stringBuilder = new StringBuilder();
                stringBuilder.append("upsert into ").append(WorkloadCountersConfigurations.COUNTERS_TABLE_NAME).append(" (").append(header).append(")").append(" values (");

                String[] tok = line.split(",");
                if(tok.length == headerTok.length){
                    for(int i=0; i<tok.length; i++){
                        String colName = headerTok[i];

                        if(colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_JOB_ID) || colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_JOB_URL) ||
                                colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_START_TIME) || colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_END_TIME) ||
                                colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_COUNTERS) || colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_CONFIGURATIONS) ||
                                colName.equalsIgnoreCase(WorkloadCountersConfigurations.COLUMN_COMPUTE_ENGINE_TYPE)   ) {
                            stringBuilder.append("'").append(tok[i]).append("',");
                        }
                        else
                            stringBuilder.append(tok[i]).append(",");
                    }

                    String sql = stringBuilder.substring(0, stringBuilder.length()-1) + ")";

                    stmt.executeUpdate(sql);
                    con.commit();
                    count++;

                }
                else {
                    errors++;
                    System.out.println();
                }


            }
            log.info("Imported Records: " + count);
            log.info("Error Records: " + errors);

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
        log.info("Done Importing WorkloadCounters");
        return  count;

    }







    public int exportWorkloadCountersIds(String filePath){
        ResultSet rset = null;
        PrintWriter writer = null;

        String sql = "select * from " + WorkloadCountersConfigurations.WORKLOAD_IDS_TABLE_NAME;
        log.info("Loading Workload ID's ... " + sql);

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

        log.info("Done Exporting Workload Ids");
        return  count;
    }



    public int importWorkloadCountersIds(String filePath){
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
                String sql = "upsert into " + WorkloadCountersConfigurations.WORKLOAD_IDS_TABLE_NAME +
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
        log.info("Done Importing Workload Ids");
        return  count;
    }


















}
