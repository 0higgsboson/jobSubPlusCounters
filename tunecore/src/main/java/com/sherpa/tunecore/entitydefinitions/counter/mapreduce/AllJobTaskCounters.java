package com.sherpa.tunecore.entitydefinitions.counter.mapreduce;

import lombok.Data;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.io.Serializable;


@Data
@JsonIgnoreProperties(ignoreUnknown = true)

public class AllJobTaskCounters  implements Serializable {

	private JobTaskCounters jobTaskCounters;

	public JobTaskCounters getJobTaskCounters() {
		return jobTaskCounters;
	}

	public void setJobTaskCounters(JobTaskCounters jobTaskCounters) {
		this.jobTaskCounters = jobTaskCounters;
	}
}
