package com.sherpa.tunecore.entitydefinitions.job.mapreduce;

import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.AllJobTaskCounters;
import lombok.Data;


import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.io.Serializable;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class Task  implements Serializable {

	private long startTime;
	private long finishTime;
	private String elapsedTime;
	
	private float progress;
	private String id;
	private String state;
	private String type;

	private String successfulAttempt;

	private AllJobTaskCounters taskCounters;


	public long getLongElapsedTime(){
		long et = 0;
		try{
			et= Long.parseLong(elapsedTime);
		}catch (NumberFormatException e){
			e.printStackTrace();
		}
		return  et;
	}


	public long getStartTime() {
		return startTime;
	}

	public void setStartTime(long startTime) {
		this.startTime = startTime;
	}

	public long getFinishTime() {
		return finishTime;
	}

	public void setFinishTime(long finishTime) {
		this.finishTime = finishTime;
	}

	public String getElapsedTime() {
		return elapsedTime;
	}

	public void setElapsedTime(String elapsedTime) {
		this.elapsedTime = elapsedTime;
	}

	public float getProgress() {
		return progress;
	}

	public void setProgress(float progress) {
		this.progress = progress;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getSuccessfulAttempt() {
		return successfulAttempt;
	}

	public void setSuccessfulAttempt(String successfulAttempt) {
		this.successfulAttempt = successfulAttempt;
	}

	public AllJobTaskCounters getTaskCounters() {
		return taskCounters;
	}

	public void setTaskCounters(AllJobTaskCounters taskCounters) {
		this.taskCounters = taskCounters;
	}
}
