package com.sherpa.core.entitydefinitions;

import java.math.BigInteger;

/**
 * Created by akhtar on 22/08/2015.
 */
public class WorkloadCounters {
    private String cpu;
    private String memory;
    private long elapsedTime;

    // following forms the key of hbase row
    private int workloadId=0;
    private long timestamp;
    private String jobId;


    public String getCpu() {
        return cpu;
    }

    public long getElapsedTime() {
        return elapsedTime;
    }

    public String getMemory() {
        return memory;
    }


    public void setCpu(String cpu) {
        this.cpu = cpu;
    }

    public void setElapsedTime(long elapsedTime) {
        this.elapsedTime = elapsedTime;
    }

    public void setMemory(String memory) {
        this.memory = memory;
    }

    public int getWorkloadId() {
        return workloadId;
    }

    public void setWorkloadId(int workloadId) {
        this.workloadId = workloadId;
    }


    public String getJobId() {
        return jobId;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setJobId(String jobId) {
        this.jobId = jobId;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    public static String getHeaders(){
        return "WorkloadID,Timestamp,JobID,CPU,Memory,JobTime";
    }

    @Override
    public String toString() {
        return workloadId + "," + timestamp + "," +jobId + "," +cpu + "," +memory + "," +elapsedTime;
    }




}
