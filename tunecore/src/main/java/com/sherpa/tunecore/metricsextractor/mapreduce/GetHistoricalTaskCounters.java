package com.sherpa.tunecore.metricsextractor.mapreduce;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.math.BigInteger;
import java.util.List;
import java.util.Properties;

import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.AllJobTaskCounters;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.TaskCounter;
import com.sherpa.tunecore.entitydefinitions.counter.mapreduce.TaskCounterGroup;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.AllJobs;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.AllTasks;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.Job;
import com.sherpa.tunecore.entitydefinitions.job.mapreduce.Task;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.client.RestTemplate;

public class GetHistoricalTaskCounters {

	private static final Logger log = LoggerFactory.getLogger(GetHistoricalTaskCounters.class);
	String propFileName = null, jobHistoryUrl = null;
	RestTemplate restTemplate = null;

	// private double cpuVCoreMilliSeconds, memoryMBSeconds, diskGB;
	BigInteger PMemBytes = new BigInteger("0");
	BigInteger CPUMSec = new BigInteger("0");
	BigInteger VMemBytes = new BigInteger("0");
	BigInteger CommittedHeapBytes = new BigInteger("0");
	
	public void getJobCounters(String JobID) throws Exception{
		
		initGetTaskCounterContext();

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
	
	private void initGetTaskCounterContext(){

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
	
	
	private void getJobCounterAggregateValue(String JobId
										   , String JobCounterName
										) {

		AllTasks allTasks = restTemplate.getForObject(jobHistoryUrl + "/" + JobId + "/tasks", AllTasks.class);
		//System.out.println(tasks);
		
		List<Task> jobTasksList = allTasks.getTasks().getTask();
		
		for(Task task : jobTasksList){
			String taskId = task.getId();
			String TaskCounterName = null;
			getTaskCounterAggregateValue(JobId, taskId, TaskCounterName);
		}

	}

	private void getTaskCounterAggregateValue(String JobId
				, String TaskId
				, String TaskCounterName
			) {

		AllJobTaskCounters allJobTaskCounters =  restTemplate.getForObject(
									jobHistoryUrl + "/" + JobId + "/tasks/" + TaskId + "/counters"
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
						System.out.println(" Printing Counters PMemBytes " + PMemBytes.toString());		
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
		// navigate and count instead of printing.
		// System.out.println(" Printing All counters");		
		System.out.println(allJobTaskCounters);

	}
	
	private void printCounterValues(){
		System.out.println(" Printing Counter Values:");
		
		System.out.println(" PMemBytes " + PMemBytes.toString() );
		System.out.println(" VMemBytes " + VMemBytes.toString() );
		System.out.println(" CommittedHeapBytes " + CommittedHeapBytes.toString() );
		System.out.println(" CPUMSec " + CPUMSec.toString() );
		
		// PMemBytes = CPUMSec = VMemBytes = CommittedHeapBytes = 0;		

	}

	public static void main(String[] args){
		GetHistoricalTaskCounters ghtc = new GetHistoricalTaskCounters();
		String JobID = "job_1437524441418_0001";
		try {
			ghtc.getJobCounters(JobID);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
}
