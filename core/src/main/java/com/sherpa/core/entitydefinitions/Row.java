package com.sherpa.core.entitydefinitions;

import java.math.BigInteger;

/**
 * Created by akhtar
 */


public class Row {

    //private String workloadId;
    private int executionTime;
    private String sherpaTuned;

    private int noReducers, mapMemory, reduceMemory, mapCores, reduceCores;
    private long maxSplitSize;

    private BigInteger mapPhysicalMemoryBytes,
                       reducePhysicalMemoryBytes,
                       mapMbMillis,
                       reduceMbMillis,
                       mapCpuMilliSeconds,
                       reduceCpuMilliSeconds,
                       hdfsBytesRead,
                       hdfsBytesWritten,
                       mapVcoresMillis,
                       reduceVcoresMillis,
                       mapMillis,
                       reduceMillis;


    public static synchronized float getFloatValue(BigInteger num, float divisor){
        float val = num.longValue();
        return val/divisor;
    }

    public float getMapMbMin(){
        return getFloatValue(mapMbMillis, 1000 * 60);
    }

    public float getReduceMbMin(){
        return getFloatValue(reduceMbMillis, 1000 * 60);
    }

    public float getMapCpuMin(){
        return getFloatValue(mapVcoresMillis, 1000 * 60);
    }

    public float getReduceCpuMin(){
        return getFloatValue(reduceVcoresMillis, 1000*60);
    }

    public BigInteger getMemoryCost(){
        return mapMbMillis.add(reduceMbMillis);
    }


    public BigInteger getCpuCost(){
        return mapVcoresMillis.add(reduceVcoresMillis);
    }


    public long getMaxSplitSizeInMb(){
        return maxSplitSize/(long)(1024*1024);
    }

    public BigInteger getLatencyCost(){
        return new BigInteger(String.valueOf(executionTime));
    }

    public BigInteger getThroughputCost(){
        return hdfsBytesRead.add(hdfsBytesWritten);
    }

    public int getExecutionTime() {
        return executionTime;
    }

    public void setExecutionTime(int executionTime) {
        this.executionTime = executionTime;
    }

    public BigInteger getHdfsBytesRead() {
        return hdfsBytesRead;
    }

    public void setHdfsBytesRead(BigInteger hdfsBytesRead) {
        this.hdfsBytesRead = hdfsBytesRead;
    }

    public BigInteger getHdfsBytesWritten() {
        return hdfsBytesWritten;
    }

    public void setHdfsBytesWritten(BigInteger hdfsBytesWritten) {
        this.hdfsBytesWritten = hdfsBytesWritten;
    }

    public int getMapCores() {
        return mapCores;
    }

    public void setMapCores(int mapCores) {
        this.mapCores = mapCores;
    }

    public BigInteger getMapCpuMilliSeconds() {
        return mapCpuMilliSeconds;
    }

    public void setMapCpuMilliSeconds(BigInteger mapCpuMilliSeconds) {
        this.mapCpuMilliSeconds = mapCpuMilliSeconds;
    }

    public BigInteger getMapMbMillis() {
        return mapMbMillis;
    }

    public void setMapMbMillis(BigInteger mapMbMillis) {
        this.mapMbMillis = mapMbMillis;
    }

    public int getMapMemory() {
        return mapMemory;
    }

    public void setMapMemory(int mapMemory) {
        this.mapMemory = mapMemory;
    }

    public BigInteger getMapMillis() {
        return mapMillis;
    }

    public void setMapMillis(BigInteger mapMillis) {
        this.mapMillis = mapMillis;
    }

    public BigInteger getMapPhysicalMemoryBytes() {
        return mapPhysicalMemoryBytes;
    }

    public void setMapPhysicalMemoryBytes(BigInteger mapPhysicalMemoryBytes) {
        this.mapPhysicalMemoryBytes = mapPhysicalMemoryBytes;
    }

    public BigInteger getMapVcoresMillis() {
        return mapVcoresMillis;
    }

    public void setMapVcoresMillis(BigInteger mapVcoresMillis) {
        this.mapVcoresMillis = mapVcoresMillis;
    }

    public long getMaxSplitSize() {
        return maxSplitSize;
    }

    public void setMaxSplitSize(long maxSplitSize) {
        this.maxSplitSize = maxSplitSize;
    }

    public int getNoReducers() {
        return noReducers;
    }

    public void setNoReducers(int noReducers) {
        this.noReducers = noReducers;
    }

    public int getReduceCores() {
        return reduceCores;
    }

    public void setReduceCores(int reduceCores) {
        this.reduceCores = reduceCores;
    }

    public BigInteger getReduceCpuMilliSeconds() {
        return reduceCpuMilliSeconds;
    }

    public void setReduceCpuMilliSeconds(BigInteger reduceCpuMilliSeconds) {
        this.reduceCpuMilliSeconds = reduceCpuMilliSeconds;
    }

    public BigInteger getReduceMbMillis() {
        return reduceMbMillis;
    }

    public void setReduceMbMillis(BigInteger reduceMbMillis) {
        this.reduceMbMillis = reduceMbMillis;
    }

    public int getReduceMemory() {
        return reduceMemory;
    }

    public void setReduceMemory(int reduceMemory) {
        this.reduceMemory = reduceMemory;
    }

    public BigInteger getReduceMillis() {
        return reduceMillis;
    }

    public void setReduceMillis(BigInteger reduceMillis) {
        this.reduceMillis = reduceMillis;
    }

    public BigInteger getReducePhysicalMemoryBytes() {
        return reducePhysicalMemoryBytes;
    }

    public void setReducePhysicalMemoryBytes(BigInteger reducePhysicalMemoryBytes) {
        this.reducePhysicalMemoryBytes = reducePhysicalMemoryBytes;
    }

    public BigInteger getReduceVcoresMillis() {
        return reduceVcoresMillis;
    }

    public void setReduceVcoresMillis(BigInteger reduceVcoresMillis) {
        this.reduceVcoresMillis = reduceVcoresMillis;
    }

    public String getSherpaTuned() {
        return sherpaTuned;
    }

    public void setSherpaTuned(String sherpaTuned) {
        this.sherpaTuned = sherpaTuned;
    }
}
