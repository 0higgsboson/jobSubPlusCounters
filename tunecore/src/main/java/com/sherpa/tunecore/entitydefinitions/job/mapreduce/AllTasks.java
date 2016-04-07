package com.sherpa.tunecore.entitydefinitions.job.mapreduce;

import lombok.Data;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.io.Serializable;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)

public class AllTasks implements Serializable{

	private String jobId;

	private Tasks tasks;

	public Tasks getTasks() {
		return tasks;
	}

	public void setTasks(Tasks tasks) {
		this.tasks = tasks;
	}

	public void setJobId(String jobId) {
		this.jobId = jobId;
	}
}
