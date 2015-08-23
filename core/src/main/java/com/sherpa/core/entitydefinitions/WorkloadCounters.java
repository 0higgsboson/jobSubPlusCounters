package com.sherpa.core.entitydefinitions;

import java.math.BigInteger;

/**
 * Created by akhtar on 22/08/2015.
 */
public class WorkloadCounters {
    private String cpu;
    private String memory;
    private long elapsedTime;

    private int workloadId=0;

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

    @Override
    public String toString() {
        return "Workload ID: " + workloadId + "\t CPU: " + cpu + "\t Memory: " + memory + "\t Job Time:"  + elapsedTime ;
    }




}
