package com.sherpa.tunecore.entitydefinitions.job.mapreduce;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

/**
 * Created by root on 9/13/15.
 */


@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class MRCounters{
    private int mapsTotal;
    private int reducesTotal;
    private int avgMapTime;
    private int avgReduceTime;
    private int avgShuffleTime;
    private int avgMergeTime;



    private String user;
    private String queue;


    public int getMapsTotal() {
        return mapsTotal;
    }

    public void setMapsTotal(int mapsTotal) {
        this.mapsTotal = mapsTotal;
    }

    public int getReducesTotal() {
        return reducesTotal;
    }

    public void setReducesTotal(int reducesTotal) {
        this.reducesTotal = reducesTotal;
    }

    public int getAvgMapTime() {
        return avgMapTime;
    }

    public void setAvgMapTime(int avgMapTime) {
        this.avgMapTime = avgMapTime;
    }

    public int getAvgReduceTime() {
        return avgReduceTime;
    }

    public void setAvgReduceTime(int avgReduceTime) {
        this.avgReduceTime = avgReduceTime;
    }

    public int getAvgShuffleTime() {
        return avgShuffleTime;
    }

    public void setAvgShuffleTime(int avgShuffleTime) {
        this.avgShuffleTime = avgShuffleTime;
    }

    public int getAvgMergeTime() {
        return avgMergeTime;
    }

    public void setAvgMergeTime(int avgMergeTime) {
        this.avgMergeTime = avgMergeTime;
    }


    public String getQueue() {
        return queue;
    }

    public void setQueue(String queue) {
        this.queue = queue;
    }

    public String getUser() {
        return user;
    }

    public void setUser(String user) {
        this.user = user;
    }
}
