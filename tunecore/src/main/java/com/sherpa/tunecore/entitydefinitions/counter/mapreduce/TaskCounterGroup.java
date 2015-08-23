package com.sherpa.tunecore.entitydefinitions.counter.mapreduce;

import java.util.List;

import lombok.Data;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class TaskCounterGroup {

	private String counterGroupName;
	
	private List<TaskCounter> counter;

	public String getCounterGroupName() {
		return counterGroupName;
	}

	public void setCounterGroupName(String counterGroupName) {
		this.counterGroupName = counterGroupName;
	}

	public List<TaskCounter> getCounter() {
		return counter;
	}

	public void setCounter(List<TaskCounter> counter) {
		this.counter = counter;
	}
}
