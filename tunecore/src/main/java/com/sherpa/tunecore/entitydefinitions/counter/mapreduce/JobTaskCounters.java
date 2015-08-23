package com.sherpa.tunecore.entitydefinitions.counter.mapreduce;

import java.util.List;

import lombok.Data;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class JobTaskCounters {

	private String id;
	private List<TaskCounterGroup> taskCounterGroup;
	
	public List<TaskCounterGroup> getTaskCounterGroup() {
		return taskCounterGroup;
	}
	public void setTaskCounterGroup(List<TaskCounterGroup> taskCounterGroup) {
		this.taskCounterGroup = taskCounterGroup;
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
}
