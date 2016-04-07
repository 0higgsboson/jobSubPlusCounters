package com.sherpa.tunecore.entitydefinitions.counter.mapreduce;

import java.io.Serializable;
import java.math.BigInteger;

import lombok.Data;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class TaskCounter  implements Serializable {

	private String name;
	private BigInteger value;
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public BigInteger getValue() {
		return value;
	}
	public void setValue(BigInteger value) {
		this.value = value;
	}
	
}
