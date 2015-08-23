package com.sherpa.tunecore.metricsextractor.mapreduce;

import com.google.gson.Gson;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.AllJobCounters;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.JobCounter;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.JobCounterGroup;
import com.sherpa.tunecore.joblauncher.MetricsDumper;
import com.sherpa.tunecore.joblauncher.SPI;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.client.RestTemplate;

import java.util.List;

public class HistoricalJobCounters {

	private static final Logger log = LoggerFactory.getLogger(HistoricalJobCounters.class);
	String jobHistoryUrl = null;
	String storageDir;
	RestTemplate restTemplate = null;
	boolean saveToDisk = true;

	public HistoricalJobCounters(String storageDir, String jobHistoryUrl) {
		this.storageDir = storageDir;
		this.jobHistoryUrl = jobHistoryUrl;
		restTemplate = new RestTemplate();
	}


	public void getJobCounters(String JobID) throws Exception{
		
		if (JobID == null) {
			return;
		}
		else {
			getJobCounterAggregateValue(JobID, null);
		}

	}

	public void setSaveToDisk(boolean saveToDisk) {
		this.saveToDisk = saveToDisk;
	}



	private void getJobCounterAggregateValue(String JobId
			   , String JobCounterName
			) {
		
		String jobCountersURI = SPI.getJobCountersUri(jobHistoryUrl, JobId);
		System.out.println("Job Counters URL:" + jobCountersURI);

		AllJobCounters jobCounters = restTemplate.getForObject(jobCountersURI, AllJobCounters.class);

		if(saveToDisk) {
			new MetricsDumper().dumpToFile("JobCounters", JobId, storageDir, new Gson().toJson(jobCounters));
		}


		List<JobCounterGroup> jobCounterGroupList = jobCounters.getJobCounters().getJobCounterGroupList();
		List<JobCounter> jobCounterList = null;
		for(JobCounterGroup jobCounterGroup : jobCounterGroupList){
			if (jobCounterGroup.getCounterGroupName().equals("org.apache.hadoop.mapreduce.JobCounter")) {
				jobCounterList = jobCounterGroup.getJobCounterList();
				if(jobCounterList!=null) {
					for (JobCounter jobCounter : jobCounterList) {
						System.out.println("Counter Name = " + jobCounter.getName());
					}
				}
			}
			else if (jobCounterGroup.getCounterGroupName().equals("org.apache.hadoop.mapreduce.TaskCounter")) {
				String x;
			}
		}

	}

	
}
