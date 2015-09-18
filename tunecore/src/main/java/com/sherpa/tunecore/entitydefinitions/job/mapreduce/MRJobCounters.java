package com.sherpa.tunecore.entitydefinitions.job.mapreduce;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

/**
 * Created by root on 9/13/15.
 */



@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class MRJobCounters {
    private MRCounters job;

    public MRCounters getJob() {
        return job;
    }

    public void setJob(MRCounters job) {
        this.job = job;
    }
}


