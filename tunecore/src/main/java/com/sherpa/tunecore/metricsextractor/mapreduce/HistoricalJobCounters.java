package com.sherpa.tunecore.metricsextractor.mapreduce;

import com.google.gson.Gson;
import com.sherpa.core.dao.HiBenchCountersConfigurations;
import com.sherpa.core.dao.WorkloadCountersConfigurations;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.AllJobCounters;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.JobCounter;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.JobCounterGroup;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.MRCounters;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.MRJobConf;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.MRJobCounters;
import com.sherpa.tunecore.joblauncher.MetricsDumper;
import com.sherpa.tunecore.joblauncher.SPI;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.client.RestTemplate;

import java.math.BigInteger;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class HistoricalJobCounters {

	private static final Logger log = LoggerFactory.getLogger(HistoricalJobCounters.class);
	String jobHistoryUrl = null;

	RestTemplate restTemplate = null;

	public HistoricalJobCounters(String jobHistoryUrl) {
		this.jobHistoryUrl = jobHistoryUrl;
		restTemplate = new RestTemplate();
	}


	public MRJobCounters getJobDetails(String jobId){
		MRJobCounters counters = restTemplate.getForObject(SPI.getJobUri(jobHistoryUrl, jobId), MRJobCounters.class);
		return  counters;
	}


	public MRJobConf getJobConf(String jobId){
		MRJobConf counters = restTemplate.getForObject(SPI.getJobConfUri(jobHistoryUrl, jobId), MRJobConf.class);
		return  counters;
	}



	public Map<String, BigInteger> getJobCounters(String JobID) throws Exception{
		
		if (JobID == null) {
			return null;
		}
		else {
			return getJobCounterAggregateValue(JobID, null);
		}

	}


	private Map<String, BigInteger> getJobCounterAggregateValue(String JobId
			   , String JobCounterName
			) {

		//Map<String, BigInteger> map = WorkloadCountersConfigurations.getInitialCounterValuesMap();
		Map<String, BigInteger> map = new HashMap<String, BigInteger>();

		String jobCountersURI = SPI.getJobCountersUri(jobHistoryUrl, JobId);
		System.out.println("Job Counters URL:" + jobCountersURI);

		AllJobCounters jobCounters = restTemplate.getForObject(jobCountersURI, AllJobCounters.class);

		List<JobCounterGroup> jobCounterGroupList = jobCounters.getJobCounters().getJobCounterGroupList();
		List<JobCounter> jobCounterList = null;

		for(JobCounterGroup jobCounterGroup : jobCounterGroupList){
				if(jobCounterGroup!=null) {
					jobCounterList = jobCounterGroup.getJobCounterList();
					if (jobCounterList != null) {
						for (JobCounter jobCounter : jobCounterList) {
							map.put(jobCounter.getName() + WorkloadCountersConfigurations.MAP_SUFFIX, BigInteger.valueOf(jobCounter.getMapCounterValue()));
							map.put(jobCounter.getName() + WorkloadCountersConfigurations.REDUCE_SUFFIX, BigInteger.valueOf(jobCounter.getReduceCounterValue()));
							map.put(jobCounter.getName() + WorkloadCountersConfigurations.TOTAL_SUFFIX, BigInteger.valueOf(jobCounter.getTotalCounterValue()));
						}
					}
				}

		}

	return map;

	}




/*
	public static void main(String[] args) throws Exception {
		RestTemplate restTemplate = new RestTemplate();
		//	MRJobCounters c = restTemplate.getForObject(SPI.getJobUri("http://master.c.test-sherpa-1015.internal:19888/ws/v1/history/mapreduce/jobs/", "job_1441908739430_0068"), MRJobCounters.class);
		//	System.out.println(c);

		HistoricalJobCounters h = new HistoricalJobCounters("http://master.c.test-sherpa-1015.internal:19888/ws/v1/history/mapreduce/jobs/");
		Map<String, BigInteger> counters = h.getJobCounters("job_1441908739430_0068");
		System.out.print(counters);



	}

*/





}
