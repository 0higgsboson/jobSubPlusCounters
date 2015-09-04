package com.sherpa.core.dao;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigInteger;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.Map;


/**
 * Created by akhtar on 01/09/2015.
 */
public class PhoenixDAO {
    private String zookeeper;
    private static Connection connection = null;
    public static final String CONNECTION_STRING = "jdbc:phoenix:";

    private static final Logger log = LoggerFactory.getLogger(PhoenixDAO.class);


    public PhoenixDAO(String zookeeperHost){
        this.zookeeper = zookeeperHost;
    }

    public Connection createConnection(){
        log.info("Opening Connection to Phoenix ...");
        if(connection==null) {
            try {
                connection = DriverManager.getConnection("jdbc:phoenix:" + zookeeper);
                log.info("Connected to Phoenix ...");
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        return  connection;
    }

    public void closeConnection(){
        log.info("Closing Phoenix Connection ...");
        try {
            if(connection!=null)
                connection.close();
            log.info("Connection Phoenix Closed ...");
        } catch (SQLException e) {
            e.printStackTrace();
        }

    }


    public void createCountersTable(){
        log.info("Creating Table ...");
        Connection con = createConnection();
        Statement stmt = null;
        try {
            stmt = con.createStatement();
            stmt.executeUpdate(WorkloadCountersConfigurations.getCreateTableSchema() );
            con.commit();
            stmt.close();
            log.info("Table created ...");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    public void saveCounters(int workloadId, String jobId, Map<String, BigInteger> values){
        String sql = "upsert into " + WorkloadCountersConfigurations.PHOENIX_TABLE_NAME + " values (" + workloadId + ",'" +jobId + "',";
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
        } catch (SQLException e) {
            e.printStackTrace();
            log.error("SQL: " + sql);
        }

    }









}
