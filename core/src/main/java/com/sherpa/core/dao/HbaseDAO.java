package com.sherpa.core.dao;

import java.io.IOException;
import java.nio.ByteBuffer;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.HColumnDescriptor;
import org.apache.hadoop.hbase.HTableDescriptor;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.HBaseAdmin;
import org.apache.hadoop.hbase.client.HTable;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.util.Bytes;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/**
 * Created by akhtar on 22/08/2015.
 */

public class HbaseDAO {
    private static final Logger log = LoggerFactory.getLogger(HbaseDAO.class);
    private static Configuration config = null;




    private Configuration getConfiguration() {
        if(config==null){
            config = HBaseConfiguration.create();
        }
        return config;
    }


    public HTable connect(String hbaseTable)
    {
        HTable table = null;
        try {
            table = new HTable(getConfiguration(), hbaseTable);

        } catch (IOException ex) {
            log.error(ex.getMessage());
        }

        return table;
    }


    public void close(HTable table){
        try {
            if(table!=null)
                table.close();
        } catch (IOException ex) {
            log.error(ex.getMessage());
        }

    }



    public boolean isTableExist(String tableName) throws IOException{
        HBaseAdmin hbase = new HBaseAdmin(getConfiguration());
        if(hbase.isTableAvailable(tableName))
            return true;
        else
            return false;
    }

    public void createTable(String tableName){
        createTable(tableName, WorkloadCountersConfigurations.DATA_COLUMN_FAMILY);
    }


    public void createTable(String tableName, String colFamily){

        try {
            if(isTableExist(tableName))
                return;


            HBaseAdmin hbase = new HBaseAdmin(getConfiguration());
            HTableDescriptor desc = new HTableDescriptor(tableName);
            HColumnDescriptor columnDescriptor = new HColumnDescriptor(colFamily);
            desc.addFamily(columnDescriptor);
            hbase.createTable(desc);
        }catch (IOException e){
            log.error(e.getMessage());
        }
    }


    public void deleteTable(String tableName){

        try {
            if(!isTableExist(tableName))
                return;

            HBaseAdmin hbase = new HBaseAdmin(getConfiguration());
            HTableDescriptor desc = new HTableDescriptor(tableName);
            hbase.disableTable(tableName);
            hbase.deleteTable(tableName);
        }catch (IOException e){
            log.error(e.getMessage());
        }
    }






}
