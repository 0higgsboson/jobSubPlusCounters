package com.sherpa.tunecore.entitydefinitions.counter.mapreduce;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

/**
 * Created by akhtar on 11/08/2015.
 */



@Data
@JsonIgnoreProperties(ignoreUnknown = true)

public class AggregatedTaskCounters {

    private String jobId;
    private String PMemBytes ;
    private String CPUMSec;
    private String VMemBytes;
    private String CommittedHeapBytes;

    public String getJobId() {
        return jobId;
    }

    public String getPMemBytes() {
        return PMemBytes;
    }

    public String getCPUMSec() {
        return CPUMSec;
    }

    public String getVMemBytes() {
        return VMemBytes;
    }

    public String getCommittedHeapBytes() {
        return CommittedHeapBytes;
    }

    public void setCommittedHeapBytes(String committedHeapBytes) {
        CommittedHeapBytes = committedHeapBytes;
    }

    public void setCPUMSec(String CPUMSec) {
        this.CPUMSec = CPUMSec;
    }

    public void setJobId(String jobId) {
        this.jobId = jobId;
    }

    public void setPMemBytes(String PMemBytes) {
        this.PMemBytes = PMemBytes;
    }

    public void setVMemBytes(String VMemBytes) {
        this.VMemBytes = VMemBytes;
    }
}
