package com.sherpa.tunecore.entitydefinitions.counter.mapreduce;

import lombok.Data;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;


@Data
@JsonIgnoreProperties(ignoreUnknown = true)

public class JobCounter {
	private String name;
	private long reduceCounterValue;
	private long mapCounterValue;
	private long totalCounterValue;
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	
	public long getReduceCounterValue() {
		return reduceCounterValue;
	}
	public void setReduceCounterValue(long reduceCounterValue) {
		this.reduceCounterValue = reduceCounterValue;
	}
	
	public long getMapCounterValue() {
		return mapCounterValue;
	}
	public void setMapCounterValue(long mapCounterValue) {
		this.mapCounterValue = mapCounterValue;
	}
	
	public long getTotalCounterValue() {
		return totalCounterValue;
	}
	public void setTotalCounterValue(long totalCounterValue) {
		this.totalCounterValue = totalCounterValue;
	}

	
}
