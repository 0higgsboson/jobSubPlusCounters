package com.sherpa.tunecore.entitydefinitions.counter.mapreduce;

import java.util.List;

import lombok.Data;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)


public class JobCounterGroup {
	private String counterGroupName;
	private List<JobCounter> jobCounterList;
	
	public String getCounterGroupName() {
		return counterGroupName;
	}
	public void setCounterGroupName(String counterGroupName) {
		this.counterGroupName = counterGroupName;
	}
	
	public List<JobCounter> getJobCounterList() {
		return jobCounterList;
	}
	public void setJobCounterList(List<JobCounter> jobCounterList) {
		this.jobCounterList = jobCounterList;
	}
}
