package com.sherpa.tunecore.entitydefinitions.counter.mapreduce;

import lombok.Data;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;



@Data
@JsonIgnoreProperties(ignoreUnknown = true)

public class AllJobTaskCounters {

	private JobTaskCounters jobTaskCounters;

	public JobTaskCounters getJobTaskCounters() {
		return jobTaskCounters;
	}

	public void setJobTaskCounters(JobTaskCounters jobTaskCounters) {
		this.jobTaskCounters = jobTaskCounters;
	}
}
