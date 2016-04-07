package com.sherpa.tunecore.metricsextractor.mapreduce;

import com.google.gson.Gson;
import com.sherpa.core.dao.WorkloadCountersConfigurations;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.AggregatedTaskCounters;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.AllJobTaskCounters;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.TaskCounter;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.TaskCounterGroup;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.*;
import com.sherpa.tunecore.joblauncher.MetricsDumper;
import com.sherpa.tunecore.joblauncher.SPI;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.client.RestTemplate;

import java.math.BigInteger;
import java.util.List;
import java.util.Map;

public class HistoricalTaskCounters {

	private static final Logger log = LoggerFactory.getLogger(HistoricalTaskCounters.class);
	String jobHistoryUrl = null;
	RestTemplate restTemplate = null;

	Map<String, BigInteger> counterValues = WorkloadCountersConfigurations.getInitialCounterValuesMap();

	public  HistoricalTaskCounters(String jobHistoryUrl){
		this.jobHistoryUrl = jobHistoryUrl;
		restTemplate = new RestTemplate();
	}


	public AllTasks getTasksCounters(String jobId){
		AllTasks allTasks = null;
		try {
			// gets all tasks
			allTasks = restTemplate.getForObject(SPI.getJobTaskUri(jobHistoryUrl, jobId), AllTasks.class);
			allTasks.setJobId(jobId);

			// iterate over tasks
			List<Task> jobTasksList = allTasks.getTasks().getTask();
			for (Task task : jobTasksList) {
				String taskId = task.getId();

				try {
					// get task level details/counters
					AllJobTaskCounters allJobTaskCounters = restTemplate.getForObject(SPI.getJobTaskCounterUri(jobHistoryUrl, jobId, taskId), AllJobTaskCounters.class);

					if(allJobTaskCounters!=null &&  allJobTaskCounters.getJobTaskCounters()!=null && allJobTaskCounters.getJobTaskCounters().getTaskCounterGroup()!=null ) {
						List<TaskCounterGroup> tcgList = allJobTaskCounters.getJobTaskCounters().getTaskCounterGroup();

						for (TaskCounterGroup tcg : tcgList) {
							tcg.setCounterGroupName(  tcg.getCounterGroupName().replaceAll("\\.", "_")   );
							if(tcg.getCounter()!=null){
								for(TaskCounter tc: tcg.getCounter()){
									tc.setName( tc.getName().replaceAll("\\.", "_") );
								}
							}
						}
						task.setTaskCounters(allJobTaskCounters);
					}
					else{
						System.out.println("Task: " + taskId + "\t details/counters null ...");
					}

				}catch (Exception e){
					e.printStackTrace();
				}

			}
		}catch (Exception e){
			e.printStackTrace();
		}

		return allTasks;
	}



	public void getJobCounters(String JobID) throws Exception{
		//log.info("Initial Counters Values: " + counterValues.toString());


		if (JobID == null) {
			AllJobs historicalJobs = restTemplate.getForObject(jobHistoryUrl, AllJobs.class);
	        
			List<Job> jobsList = historicalJobs.getJobs().getJob();
			log.info("historical jobs" + historicalJobs);
	        
			//System.out.println(jobsList);
			
			String jobId = null;
			for(Job jobs : jobsList ){			
				jobId = jobs.getId();
				getJobCounterAggregateValue(jobId, null);
			}			
		}
		else {
			getJobCounterAggregateValue(JobID, null);
		}
					

	}



	private void getJobCounterAggregateValue(String JobId
										   , String JobCounterName
										) {

		AllTasks allTasks = restTemplate.getForObject(SPI.getJobTaskUri(jobHistoryUrl, JobId), AllTasks.class);
		allTasks.setJobId(JobId);

		//new MetricsDumper().dumpToFile("TaskCounters", JobId, storageDir, new Gson().toJson(allTasks) );


		List<Task> jobTasksList = allTasks.getTasks().getTask();
		
		for(Task task : jobTasksList){
			String taskId = task.getId();
			String TaskCounterName = null;
			//getTaskCounterAggregateValue(JobId, taskId, TaskCounterName);
			aggregateTaskCounters(JobId, taskId, TaskCounterName);
		}


	}


	private void aggregateTaskCounters(String JobId, String TaskId, String TaskCounterName) {

		AllJobTaskCounters allJobTaskCounters =  restTemplate.getForObject(SPI.getJobTaskCounterUri(jobHistoryUrl, JobId, TaskId), AllJobTaskCounters.class);
		List<TaskCounterGroup> tcgList = allJobTaskCounters.getJobTaskCounters().getTaskCounterGroup();



		String tcgName;
		String taskCounterGroupName;
		if(tcgList==null)
			return;

		for (TaskCounterGroup tcg:tcgList){
			tcgName = tcg.getCounterGroupName();
			if(tcgName!=null && !tcgName.isEmpty()) {
				//log.info("Task Group Name: " + tcgName);
				String tok[] = tcgName.split("\\.");
				if(tok.length==1)
					taskCounterGroupName = tok[0];
				else
					taskCounterGroupName = tok[tok.length - 1];

				List<TaskCounter> tcList = tcg.getCounter();

				for (TaskCounter tc : tcList) {
					//log.info("Counter Name: " + tc.getName() + "\t Counter Value: " + tc.getValue());

					if(taskCounterGroupName.equalsIgnoreCase("Shuffle Errors"))
						taskCounterGroupName = "ShuffleErrors";

					String column = taskCounterGroupName + "_" + tc.getName();
					//log.info("Column: " + column);
					if (counterValues.containsKey(column)) {
						BigInteger tmp = counterValues.get(column).add(tc.getValue());
						counterValues.put(column, tmp);
					} else {
						log.info("\n\nError: Column does not exist in column names map: " + column);
					}

				}
			}

		}

	}


	public Map<String, BigInteger> getCounterValues() {
		return counterValues;
	}



	public BigInteger computeReservedMemory(String JobId, BigInteger mapMemory, BigInteger reduceMemory) {
		BigInteger reservedMemory = new BigInteger("0");
		BigInteger productResult;
		AllTasks allTasks = restTemplate.getForObject(SPI.getJobTaskUri(jobHistoryUrl, JobId), AllTasks.class);


		List<Task> jobTasksList = allTasks.getTasks().getTask();

		for(Task task : jobTasksList){
			if(task.getType().equalsIgnoreCase("MAP")){
				productResult = mapMemory.multiply(new BigInteger(task.getElapsedTime()));
				reservedMemory = reservedMemory.add(productResult);
			}
			else if(task.getType().equalsIgnoreCase("REDUCE")){
				productResult = reduceMemory.multiply(new BigInteger(task.getElapsedTime()));
				reservedMemory = reservedMemory.add(productResult);
			}
		}

		return reservedMemory;
	}



	public BigInteger computeReservedCpu(String JobId, BigInteger mapCores, BigInteger reduceCores) {
		BigInteger reservedCpu = new BigInteger("0");
		BigInteger productResult;
		AllTasks allTasks = restTemplate.getForObject(SPI.getJobTaskUri(jobHistoryUrl, JobId), AllTasks.class);


		List<Task> jobTasksList = allTasks.getTasks().getTask();

		for(Task task : jobTasksList){
			if(task.getType().equalsIgnoreCase("MAP")){
				productResult = mapCores.multiply(new BigInteger(task.getElapsedTime()));
				reservedCpu = reservedCpu.add(productResult);
			}
			else if(task.getType().equalsIgnoreCase("REDUCE")){
				productResult = reduceCores.multiply(new BigInteger(task.getElapsedTime()));
				reservedCpu = reservedCpu.add(productResult);
			}
		}

		return reservedCpu;
	}




	public long computeLatency(String JobId) {
		long maxMapLatency    = Long.MIN_VALUE;
		long maxReduceLatency = Long.MIN_VALUE;
		System.out.println("\nComputing Latency for Job: " + JobId);
		try {
			AllTasks allTasks = restTemplate.getForObject(SPI.getJobTaskUri(jobHistoryUrl, JobId), AllTasks.class);
			List<Task> jobTasksList = allTasks.getTasks().getTask();
			for (Task task : jobTasksList) {
				if (task.getType().equalsIgnoreCase("MAP")) {
					maxMapLatency = Math.max(maxMapLatency, task.getLongElapsedTime());
				} else if (task.getType().equalsIgnoreCase("REDUCE")) {
					maxReduceLatency = Math.max(maxReduceLatency, task.getLongElapsedTime());
				}
			}
			System.out.println("\nDone Computing Latency for Job: " + JobId);
		}catch (Exception e){
			e.printStackTrace();
		}

		if(maxMapLatency < 0)
			maxMapLatency = 0;

		if(maxReduceLatency < 0)
			maxReduceLatency = 0;

		System.out.println("\n Max Map Latency: " + maxMapLatency + "\t Max Reduce Latency: " + maxReduceLatency + "\t Latency: " + (maxMapLatency + maxReduceLatency));
		return (maxMapLatency + maxReduceLatency);
	}




	public static void main(String[] args) throws Exception {
	//	RestTemplate restTemplate = new RestTemplate();
//		MRJobCounters c = restTemplate.getForObject(SPI.getJobUri("http://104.197.176.154:19888/ws/v1/history/mapreduce/jobs/", "job_1447069154965_0002"), MRJobCounters.class);
//		System.out.println(c);

		HistoricalTaskCounters tc = new HistoricalTaskCounters("http://104.197.122.66:19888/ws/v1/history/mapreduce/jobs/");
		AllTasks tasks = tc.getTasksCounters("job_1459508871579_0036");
		System.out.println(tasks.getTasks().getTask().size());

	}


}
