package com.sherpa.core.entitydefinitions;

import java.math.BigInteger;
import java.util.Properties;

/**
 * Created by akhtar on 11/12/2015.
 */


public class Parameters {
    private double cost = -1;
    private String maxSplitSize;
    private String jobReduces;
    private String mapMemMb;
    private String reduceMemMb;
    private String mapCpuCores;
    private String reduceCpuCores;



    public Properties getConfigsAsProperties(){
        Properties properties = new Properties();
        properties.put("mapreduce_map_cpu_vcores", mapCpuCores);
        properties.put("mapreduce_reduce_cpu_vcores", reduceCpuCores);

        properties.put("mapreduce_map_memory_mb", mapMemMb);
        properties.put("mapreduce_reduce_memory_mb", reduceMemMb);

        properties.put("mapreduce_job_reduces", jobReduces);
        properties.put("mapreduce_max_split_size", maxSplitSize);

        return  properties;
    }


    public double getCost() {
        return cost;
    }

    public void setCost(double cost) {
        this.cost = cost;
    }

    public String getJobReduces() {
        return jobReduces;
    }

    public void setJobReduces(String jobReduces) {
        this.jobReduces = jobReduces;
    }

    public String getMapCpuCores() {
        return mapCpuCores;
    }

    public void setMapCpuCores(String mapCpuCores) {
        this.mapCpuCores = mapCpuCores;
    }

    public String getMapMemMb() {
        return mapMemMb;
    }

    public void setMapMemMb(String mapMemMb) {
        this.mapMemMb = mapMemMb;
    }

    public String getMaxSplitSize() {
        return maxSplitSize;
    }

    public void setMaxSplitSize(String maxSplitSize) {
        this.maxSplitSize = maxSplitSize;
    }

    public String getReduceCpuCores() {
        return reduceCpuCores;
    }

    public void setReduceCpuCores(String reduceCpuCores) {
        this.reduceCpuCores = reduceCpuCores;
    }

    public String getReduceMemMb() {
        return reduceMemMb;
    }

    public void setReduceMemMb(String reduceMemMb) {
        this.reduceMemMb = reduceMemMb;
    }

    @Override
    public String toString() {
        return "\n(Cost=" + cost + ", Split Size="+ maxSplitSize + ", Reducers=" + jobReduces  + ", Map Mem=" + mapMemMb  + ", Reduce Mem=" + reduceMemMb  + ", Map Cores=" + mapCpuCores  + ", Reduce Cores=" + reduceCpuCores  + ")";
    }
}
