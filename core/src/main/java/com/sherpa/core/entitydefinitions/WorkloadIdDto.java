package com.sherpa.core.entitydefinitions;

/**
 * Created by akhtar on 08/09/2015.
 */
public class WorkloadIdDto {
    private int workloadId;
    private String date;
    private long hash;


    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }


    public int getWorkloadId() {
        return workloadId;
    }

    public void setWorkloadId(int workloadId) {
        this.workloadId = workloadId;
    }


    public long getHash() {
        return hash;
    }

    public void setHash(long hash) {
        this.hash = hash;
    }
}
