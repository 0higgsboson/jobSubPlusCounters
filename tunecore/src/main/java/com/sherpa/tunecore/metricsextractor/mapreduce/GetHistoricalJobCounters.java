package com.sherpa.tunecore.metricsextractor.mapreduce;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.List;
import java.util.Properties;

import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.AllJobCounters;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.JobCounter;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.JobCounterGroup;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.client.RestTemplate;

public class GetHistoricalJobCounters {

	private static final Logger log = LoggerFactory.getLogger(GetHistoricalJobCounters.class);
	String propFileName = null, jobHistoryUrl = null;
	RestTemplate restTemplate = null;
	
	public void getJobCounters(String JobID) throws Exception{
		
		initGetJobCounterContext();

		if (JobID == null) {
			return;
		}
		else {
			getJobCounterAggregateValue(JobID, null);
		}
					
		// printCounterValues();

	}

	private void getJobCounterAggregateValue(String JobId
			   , String JobCounterName
			) {
		
		String jobCountersURI = jobHistoryUrl + "/" + JobId + "/counters";

		System.out.println("Job History URL: " + jobCountersURI);

		AllJobCounters jobCounters = restTemplate.getForObject(jobCountersURI, AllJobCounters.class);
		System.out.println(jobCounters);
		
		List<JobCounterGroup> jobCounterGroupList = jobCounters.getJobCounters().getJobCounterGroupList();
		List<JobCounter> jobCounterList = null;
		for(JobCounterGroup jobCounterGroup : jobCounterGroupList){
			if (jobCounterGroup.getCounterGroupName().equals("org.apache.hadoop.mapreduce.JobCounter")) {
				jobCounterList = jobCounterGroup.getJobCounterList(); 
				for (JobCounter  jobCounter: jobCounterList){
					System.out.println("Counter Name = " + jobCounter.getName());
				}
			}
			else if (jobCounterGroup.getCounterGroupName().equals("org.apache.hadoop.mapreduce.TaskCounter")) {
				String x;
			}
		}

	}
	
	private void initGetJobCounterContext(){

		Properties prop = new Properties();
		propFileName = "/Users/sadiqshaik/code/workinprogress/setup/pmibSetup/rest.conf";
		  // "/opt/perfsherpa/config/rest.conf";
		
		try {
			prop.load(new FileInputStream(propFileName));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		jobHistoryUrl = prop.getProperty("jobhistory.url");

		restTemplate = new RestTemplate();		
	}
	
	public static void main(String[] args){
		GetHistoricalJobCounters ghjc = new GetHistoricalJobCounters();
		String JobID = "job_1437524441418_0001";
		try {
			ghjc.getJobCounters(JobID);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
}
