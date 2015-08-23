package com.sherpa.tunecore.entitydefinitions.job.mapreduce;

import lombok.Data;

import org.joda.time.DateTime;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class Job{

	private DateTime submitTime;
	private DateTime startTime;
	private DateTime finishTime;
	
	private String id;
	private String name;
	private String queue;
	private String user;
	private String state;
	private int mapsTotal;
	private int mapsCompleted;
	private int reducesTotal;
	
	private int reducesCompleted;

	public DateTime getSubmitTime() {
		return submitTime;
	}

	public void setSubmitTime(DateTime submitTime) {
		this.submitTime = submitTime;
	}

	public DateTime getStartTime() {
		return startTime;
	}

	public void setStartTime(DateTime startTime) {
		this.startTime = startTime;
	}

	public DateTime getFinishTime() {
		return finishTime;
	}

	public void setFinishTime(DateTime finishTime) {
		this.finishTime = finishTime;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getQueue() {
		return queue;
	}

	public void setQueue(String queue) {
		this.queue = queue;
	}

	public String getUser() {
		return user;
	}

	public void setUser(String user) {
		this.user = user;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public int getMapsTotal() {
		return mapsTotal;
	}

	public void setMapsTotal(int mapsTotal) {
		this.mapsTotal = mapsTotal;
	}

	public int getMapsCompleted() {
		return mapsCompleted;
	}

	public void setMapsCompleted(int mapsCompleted) {
		this.mapsCompleted = mapsCompleted;
	}

	public int getReducesTotal() {
		return reducesTotal;
	}

	public void setReducesTotal(int reducesTotal) {
		this.reducesTotal = reducesTotal;
	}

	public int getReducesCompleted() {
		return reducesCompleted;
	}

	public void setReducesCompleted(int reducesCompleted) {
		this.reducesCompleted = reducesCompleted;
	}
}
