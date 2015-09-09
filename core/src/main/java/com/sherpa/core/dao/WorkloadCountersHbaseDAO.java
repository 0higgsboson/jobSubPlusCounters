package com.sherpa.core.dao;

import com.sherpa.core.entitydefinitions.WorkloadCounters;
import org.apache.hadoop.hbase.KeyValue;
import org.apache.hadoop.hbase.client.*;
import org.apache.hadoop.hbase.util.Bytes;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Created by akhtar on 22/08/2015.
 */
public class WorkloadCountersHbaseDAO extends HbaseDAO{

    private static final Logger log = LoggerFactory.getLogger(WorkloadCountersHbaseDAO.class);



    public static String getWorkloadCountersTableName(){
        return WorkloadCountersConfigurations.TABLE_NAME;
    }



    public void saveWorkloadCounters(String tableName, ByteBuffer rowKey, WorkloadCounters workloadCounters)  {
        log.info("Saving WorkloadCounters: " + workloadCounters);
        try {
            HTable table = connect(tableName);
            Put put = new Put(rowKey.array());
            put.addColumn(Bytes.toBytes(WorkloadCountersConfigurations.DATA_COLUMN_FAMILY),
                          Bytes.toBytes(WorkloadCountersConfigurations.CPU_COLUMN_NAME),
                          Bytes.toBytes(workloadCounters.getCpu())
                    );

            put.addColumn(Bytes.toBytes(WorkloadCountersConfigurations.DATA_COLUMN_FAMILY),
                    Bytes.toBytes(WorkloadCountersConfigurations.MEMORY_COLUMN_NAME),
                    Bytes.toBytes(workloadCounters.getMemory())
            );

            put.addColumn(Bytes.toBytes(WorkloadCountersConfigurations.DATA_COLUMN_FAMILY),
                    Bytes.toBytes(WorkloadCountersConfigurations.JOB_TIME_COLUMN_NAME),
                    Bytes.toBytes(workloadCounters.getElapsedTime())
            );

            table.put(put);
            table.flushCommits();
            close(table);
            log.info("Done saving WorkloadCounters ... ");
        }
        catch (Exception e){
            e.printStackTrace();
            log.error(e.getMessage());
        }

    }





    public WorkloadCounters getWorkloadCounters(String tableName, ByteBuffer rowKey)  {
        WorkloadCounters workloadCounters = null;
        log.info("Loading  workloadcounters ");

        try {
            Result result = null;
            HTable table = connect(tableName);
            Get get = new Get(rowKey.array());
            result = table.get(get);
            workloadCounters = parseWorkloadCounters(result);
            close(table);
            log.info("Done loading workloadcounters ...");
        }
        catch (Exception e){
            e.printStackTrace();
            log.error(e.getMessage());
        }

        return workloadCounters;
    }



    public List<WorkloadCounters> getAllWorkloadCounters(String tableName){
        List<WorkloadCounters> workloadCounters = new ArrayList<WorkloadCounters>();
        log.info("Loading all workload counters ...");

        try {
            HTable table = connect(tableName);
            Scan scan = new Scan();
            ResultScanner scannar = table.getScanner(scan);
            Iterator<Result> results = scannar.iterator();

            while(results!=null && results.hasNext()){
                Result result = results.next();
                workloadCounters.add(parseWorkloadCounters(result));
            }
            scannar.close();
            close(table);
            log.info("Done loading all workload counters ...");

        }
        catch (Exception e){
            e.printStackTrace();
            log.error(e.getMessage());
        }

        return workloadCounters;
    }




    private WorkloadCounters parseWorkloadCounters(Result result){
        WorkloadCounters workloadCounters = null;
        log.info("Parsing workloadcounters");
        if(result!=null && !result.isEmpty()){
            try{

                /**
                 * for debugging only
                  */
            displayHbaseResult(result);
                /*****/

                workloadCounters = getWorkloadCounterFromKey(result.getRow());
                workloadCounters.setCpu(Bytes.toString(result.getValue(Bytes.toBytes(WorkloadCountersConfigurations.DATA_COLUMN_FAMILY), Bytes.toBytes(WorkloadCountersConfigurations.CPU_COLUMN_NAME))));
                workloadCounters.setMemory(Bytes.toString(result.getValue(Bytes.toBytes(WorkloadCountersConfigurations.DATA_COLUMN_FAMILY), Bytes.toBytes(WorkloadCountersConfigurations.MEMORY_COLUMN_NAME))));
                workloadCounters.setElapsedTime(Bytes.toLong(result.getValue(Bytes.toBytes(WorkloadCountersConfigurations.DATA_COLUMN_FAMILY), Bytes.toBytes(WorkloadCountersConfigurations.JOB_TIME_COLUMN_NAME))));
                log.info("Done parsing workloadcounters");

            }catch (Exception e){
                e.printStackTrace();
                log.error(e.getMessage());
            }
        }
        return workloadCounters;
    }


    public  ByteBuffer getWorkloadCounterRowKey(int workloadId, long time, String jobId){
        int size=4 + 8 + jobId.length();
        ByteBuffer buffer = ByteBuffer.allocate(size);

        buffer.putInt(workloadId);
        buffer.putLong(time);
        buffer.put(Bytes.toBytes(jobId));

        buffer.rewind();
        return buffer;

    }



    public  ByteBuffer getWorkloadCounterRowKey(int workloadId, long time){
        int size=4 + 8;
        ByteBuffer buffer = ByteBuffer.allocate(size);

        buffer.putInt(workloadId);
        buffer.putLong(time);

        buffer.rewind();
        return buffer;

    }


    public  ByteBuffer getWorkloadCounterRowKey(int workloadId){
        int size=4;
        ByteBuffer buffer = ByteBuffer.allocate(size);

        buffer.putInt(workloadId);
        buffer.rewind();
        return buffer;

    }




    public  WorkloadCounters getWorkloadCounterFromKey(byte[] key){
        log.info("Key Length: " + key.length);

        WorkloadCounters workloadCounters = new WorkloadCounters();
        ByteBuffer buffer = ByteBuffer.allocate(key.length);
        buffer.put(key);
        buffer.rewind();
        byte[] arr = new byte[key.length - 12];

        log.info("Arr Length: " + arr.length);

        workloadCounters.setWorkloadId(buffer.getInt());
        workloadCounters.setTimestamp(buffer.getLong());
        buffer.get(arr, 0, arr.length);
        workloadCounters.setJobId(Bytes.toString(arr));
        return workloadCounters;
    }



    public void displayHbaseResult(Result result){
        log.info("Displaying Hbase Result Values ...");
        WorkloadCounters wc = getWorkloadCounterFromKey(result.getRow());
        System.out.println("Row Key =>  Workload ID: " + wc.getWorkloadId()  + "\t Timestamp: " + wc.getTimestamp() + "\t Job ID: " + wc.getJobId() );

        for(KeyValue kv: result.raw()){
                System.out.print("Colulm  Family: " + Bytes.toString(kv.getFamily()) );
                System.out.print("\t Colulm  Name: " + Bytes.toString(kv.getQualifier()) );
                System.out.print("\t Colulm  Value: " + Bytes.toString(kv.getValue()) );
                System.out.println();
        }
    }




}
