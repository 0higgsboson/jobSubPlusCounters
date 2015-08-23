package com.sherpa.tunecore.entitydefinitions.counter.mapreduce;

import java.util.List;

import lombok.Data;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)

public class JobCounters {
	private String id;
	private List<JobCounterGroup> counterGroup;

	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	
	public List<JobCounterGroup> getJobCounterGroupList() {
		return counterGroup;
	}
	public void setJobCounterGroupList(List<JobCounterGroup> jobCounterGroupList) {
		this.counterGroup = jobCounterGroupList;
	}

}
