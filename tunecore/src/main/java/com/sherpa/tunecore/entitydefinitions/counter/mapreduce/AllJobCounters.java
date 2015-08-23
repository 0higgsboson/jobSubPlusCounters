package com.sherpa.tunecore.entitydefinitions.counter.mapreduce;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

/**
 * Created by akhtar on 10/08/2015.
 */




@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class AllJobCounters {
    private JobCounters jobCounters;

    public JobCounters getJobCounters() {
        return jobCounters;
    }


    public void setJobCounters(JobCounters jobCounters) {
        this.jobCounters = jobCounters;
    }
}
