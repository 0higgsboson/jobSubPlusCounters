package com.sherpa.tunecore.metricsextractor.mapreduce;

import com.google.gson.Gson;
import com.sherpa.core.dao.HiBenchCountersConfigurations;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.AllJobCounters;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.JobCounter;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.JobCounterGroup;
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

		Map<String, BigInteger> map = HiBenchCountersConfigurations.getInitialCounterValuesMap();


		String jobCountersURI = SPI.getJobCountersUri(jobHistoryUrl, JobId);
		System.out.println("Job Counters URL:" + jobCountersURI);

		AllJobCounters jobCounters = restTemplate.getForObject(jobCountersURI, AllJobCounters.class);

		/*if(saveToDisk) {
			new MetricsDumper().dumpToFile("JobCounters", JobId, storageDir, new Gson().toJson(jobCounters));
		}
*/

		List<JobCounterGroup> jobCounterGroupList = jobCounters.getJobCounters().getJobCounterGroupList();
		List<JobCounter> jobCounterList = null;



		for(JobCounterGroup jobCounterGroup : jobCounterGroupList){
				if(jobCounterGroup!=null) {
					jobCounterList = jobCounterGroup.getJobCounterList();
					if (jobCounterList != null) {
						for (JobCounter jobCounter : jobCounterList) {
							//System.out.println("Counter Name = " + jobCounter.getName() + " " + jobCounter);

							if(jobCounter.getName().equalsIgnoreCase("TOTAL_LAUNCHED_MAPS")){
								map.put("TOTAL_MAPPERS", BigInteger.valueOf(jobCounter.getTotalCounterValue()));
							}
							else if(jobCounter.getName().equalsIgnoreCase("TOTAL_LAUNCHED_REDUCES")){
								map.put("TOTAL_REDUCERS", BigInteger.valueOf(jobCounter.getTotalCounterValue()));
							}
							else if(jobCounter.getName().equalsIgnoreCase("VCORES_MILLIS_MAPS")){
								map.put("MAP_VCORE_TIME", BigInteger.valueOf(jobCounter.getTotalCounterValue()));
							}
							else if(jobCounter.getName().equalsIgnoreCase("VCORES_MILLIS_REDUCES")){
								map.put("REDUCE_VCORE_TIME", BigInteger.valueOf(jobCounter.getTotalCounterValue()));
							}
							else if(jobCounter.getName().equalsIgnoreCase("CPU_MILLISECONDS")){
								map.put("REDUCE_TIME", BigInteger.valueOf(jobCounter.getReduceCounterValue()));
								map.put("MAP_TIME", BigInteger.valueOf(jobCounter.getMapCounterValue()));

							}
							else if(jobCounter.getName().equalsIgnoreCase("PHYSICAL_MEMORY_BYTES")){
								long mb = jobCounter.getMapCounterValue()/(1000*1000);
								map.put("MAP_PHYSICAL_MEM_BYTES", BigInteger.valueOf(jobCounter.getMapCounterValue()));
								map.put("MAP_PHYSICAL_MEM_MB", BigInteger.valueOf(mb));

								map.put("REDUCE_PHYSICAL_MEM", BigInteger.valueOf(jobCounter.getReduceCounterValue()));
							}
							else if(jobCounter.getName().equalsIgnoreCase("VIRTUAL_MEMORY_BYTES")){
								long mb = jobCounter.getMapCounterValue()/(1000*1000);
								map.put("MAP_VIRTUAL_MEM_BYTES", BigInteger.valueOf(jobCounter.getMapCounterValue()));
								map.put("MAP_VIRTUAL_MEM_MB", BigInteger.valueOf(mb));

								map.put("REDUCE_VIRTUAL_MEM", BigInteger.valueOf(jobCounter.getReduceCounterValue()));

							}


						}
					}
				}

		}

	return map;

	}




	public static void main(String[] args) throws Exception {
		RestTemplate restTemplate = new RestTemplate();
		//	MRJobCounters c = restTemplate.getForObject(SPI.getJobUri("http://master.c.test-sherpa-1015.internal:19888/ws/v1/history/mapreduce/jobs/", "job_1441908739430_0068"), MRJobCounters.class);
		//	System.out.println(c);

		HistoricalJobCounters h = new HistoricalJobCounters("http://master.c.test-sherpa-1015.internal:19888/ws/v1/history/mapreduce/jobs/");
		h.getJobCounters("job_1441908739430_0068");

	}






}
