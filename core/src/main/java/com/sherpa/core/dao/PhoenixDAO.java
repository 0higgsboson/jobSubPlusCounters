package com.sherpa.core.dao;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigInteger;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
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
        log.info("Opening Connection to Phoenix: " + zookeeper);
        if(connection==null) {
            try {
                connection = DriverManager.getConnection("jdbc:phoenix:" + zookeeper);
                log.info("Connected to Phoenix: " + zookeeper);
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


    public void createTable(String tableSchema){
        log.info("Creating Table: " + tableSchema);
        Connection con = createConnection();
        Statement stmt = null;
        try {
            stmt = con.createStatement();
            stmt.executeUpdate(tableSchema );
            con.commit();
            stmt.close();
            log.info("Table created ...");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }











}
