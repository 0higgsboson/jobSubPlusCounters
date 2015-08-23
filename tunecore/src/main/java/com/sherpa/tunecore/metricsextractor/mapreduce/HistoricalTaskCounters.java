package com.sherpa.tunecore.metricsextractor.mapreduce;

import com.google.gson.Gson;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.AggregatedTaskCounters;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.AllJobTaskCounters;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.TaskCounter;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.TaskCounterGroup;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.AllJobs;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.AllTasks;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.Job;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.Task;
import com.sherpa.tunecore.joblauncher.MetricsDumper;
import com.sherpa.tunecore.joblauncher.SPI;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.client.RestTemplate;

import java.math.BigInteger;
import java.util.List;

public class HistoricalTaskCounters {

	private static final Logger log = LoggerFactory.getLogger(HistoricalTaskCounters.class);
	String jobHistoryUrl = null;
	String storageDir;
	RestTemplate restTemplate = null;
	boolean saveToDisk = true;

	// private double cpuVCoreMilliSeconds, memoryMBSeconds, diskGB;
	BigInteger PMemBytes = new BigInteger("0");
	BigInteger CPUMSec = new BigInteger("0");
	BigInteger VMemBytes = new BigInteger("0");
	BigInteger CommittedHeapBytes = new BigInteger("0");


	public  HistoricalTaskCounters(String storageDir, String jobHistoryUrl){
		this.storageDir = storageDir;
		this.jobHistoryUrl = jobHistoryUrl;
		restTemplate = new RestTemplate();
	}


	public void setSaveToDisk(boolean saveToDisk) {
		this.saveToDisk = saveToDisk;
	}

	public void getJobCounters(String JobID) throws Exception{

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
					
		//System.out.println(historicalJobs);
		printCounterValues();

	}



	private void getJobCounterAggregateValue(String JobId
										   , String JobCounterName
										) {

		AllTasks allTasks = restTemplate.getForObject(SPI.getJobTaskUri(jobHistoryUrl, JobId), AllTasks.class);
		allTasks.setJobId(JobId);

		new MetricsDumper().dumpToFile("TaskCounters", JobId, storageDir, new Gson().toJson(allTasks) );


		List<Task> jobTasksList = allTasks.getTasks().getTask();
		
		for(Task task : jobTasksList){
			String taskId = task.getId();
			String TaskCounterName = null;
			getTaskCounterAggregateValue(JobId, taskId, TaskCounterName);
		}


		// saves counters
		save(JobId);

	}


	private void save(String JobId) {
		if (saveToDisk) {
			AggregatedTaskCounters aggregatedTaskCounters = new AggregatedTaskCounters();
			aggregatedTaskCounters.setJobId(JobId);
			aggregatedTaskCounters.setCommittedHeapBytes(CommittedHeapBytes.toString());
			aggregatedTaskCounters.setCPUMSec(CPUMSec.toString());
			aggregatedTaskCounters.setPMemBytes(PMemBytes.toString());
			aggregatedTaskCounters.setVMemBytes(VMemBytes.toString());

			new MetricsDumper().dumpToFile("Aggregated_TaskCounters", JobId, storageDir, new Gson().toJson(aggregatedTaskCounters));

		}
	}


	private void getTaskCounterAggregateValue(String JobId
				, String TaskId
				, String TaskCounterName
			) {

		AllJobTaskCounters allJobTaskCounters =  restTemplate.getForObject(
									SPI.getJobTaskCounterUri(jobHistoryUrl,JobId,TaskId)
								  , AllJobTaskCounters.class);
		
		// System.out.println(" Printing Get Job counters");
		// System.out.println();
		List<TaskCounterGroup> tcgList = allJobTaskCounters.getJobTaskCounters().getTaskCounterGroup();
		
		String tcgName = null;
		// BigInteger taskCounterValue = null;

		for (TaskCounterGroup tcg:tcgList){
			tcgName = tcg.getCounterGroupName();
			// System.out.println(" counter group name = " + tcgName);
			if (tcgName.equals("org.apache.hadoop.mapreduce.TaskCounter")) {
				// other values are-- org.apache.hadoop.mapreduce.FileSystemCounter, org.apache.hadoop.mapreduce.lib.input.FileInputFormatCounter
				
				// System.out.println(" inside tcgname debug");
				List <TaskCounter> tcList = tcg.getCounter();
				// Use hadoop's taskcounter class.  Refactor in future.
				
				for (TaskCounter tc:tcList) {
					// System.out.println(" Counter name = " + tc.getName() + " Counter value = " + tc.getValue());
					// taskCounterName = tc.getName();
					// taskCounterValue = tc.getValue();
					if (tc.getName().equals("CPU_MILLISECONDS")) {
						// System.out.println(" Counter name = " + tc.getName() + " Counter value = " + tc.getValue());
						CPUMSec = CPUMSec.add(tc.getValue());
						// System.out.println(" Printing Counters CPUMSec " + CPUMSec.toString());		
					}
					else if (tc.getName().equals("PHYSICAL_MEMORY_BYTES")) {
						PMemBytes = PMemBytes.add(tc.getValue());
					}
					else if (tc.getName().equals("VIRTUAL_MEMORY_BYTES")) {
						VMemBytes = VMemBytes.add(tc.getValue());
					}
					else if (tc.getName().equals("COMMITTED_HEAP_BYTES")) {
						CommittedHeapBytes = CommittedHeapBytes.add(tc.getValue());
					}
					// PMemBytes = CPUMSec = VMemBytes = CommittedHeapBytes = 0;
				}
			}
		}

	}
	
	private void printCounterValues(){
		System.out.println(" Printing Counter Values:");
		
		System.out.println(" PMemBytes " + PMemBytes.toString() );
		System.out.println(" VMemBytes " + VMemBytes.toString() );
		System.out.println(" CommittedHeapBytes " + CommittedHeapBytes.toString() );
		System.out.println(" CPUMSec " + CPUMSec.toString() );
		
		// PMemBytes = CPUMSec = VMemBytes = CommittedHeapBytes = 0;		

	}


	public BigInteger getCommittedHeapBytes() {
		return CommittedHeapBytes;
	}

	public BigInteger getCPUMSec() {
		return CPUMSec;
	}

	public BigInteger getPMemBytes() {
		return PMemBytes;
	}

	public BigInteger getVMemBytes() {
		return VMemBytes;
	}






}
