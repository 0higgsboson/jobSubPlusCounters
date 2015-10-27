package com.sherpa.core.bl;

import com.google.common.collect.Lists;
import com.sherpa.core.dao.WorkloadCountersPhoenixDAO;
import com.sherpa.core.entitydefinitions.WorkloadIdDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;

/**
 * Created by akhtar on 07/09/2015.
 */
public class WorkloadIdGenerator {
    private static final Logger log = LoggerFactory.getLogger(WorkloadIdGenerator.class);


    private Map<Long, Integer> workloadHashToIdMap;
    private WorkloadCountersPhoenixDAO phoenixDAO;
    private int nextWorkLoadId = 1;

    public WorkloadIdGenerator(WorkloadCountersPhoenixDAO dao){
        workloadHashToIdMap = new HashMap<Long, Integer>();
        this.phoenixDAO = dao;
        init();
    }


    private void init(){
        List<WorkloadIdDto> list = phoenixDAO.loadAllWorkloadIds();
        for(WorkloadIdDto dto: list){
            workloadHashToIdMap.put(dto.getHash(), dto.getWorkloadId());
            if(dto.getWorkloadId() >= nextWorkLoadId)
                nextWorkLoadId = dto.getWorkloadId() + 1;
        }

        log.info("WorkloadIdGenerator Initialized: " + workloadHashToIdMap.keySet().size());
        log.info("Hash To ID Map: " + workloadHashToIdMap);
        System.out.println("Hash To ID Map: " + workloadHashToIdMap);
    }


    private int getWorkloadId(String workload){

        if(workload.isEmpty()){
            log.info("Error: cant assign workflow id to empty workload");
            return -1;
        }

        int wid = 0;
        long hash = hashCode(workload);

        if(workloadHashToIdMap.containsKey(hash)) {
           // log.info("Workload ID found for Workload: " + workload);
           // System.out.println("Workload ID found for Workload: " + workload);
            wid = workloadHashToIdMap.get(hash);
        }
        else{
            wid = nextWorkLoadId++;
            log.info("Adding new Workload ID in DB: " + wid);
            System.out.println("Adding new Workload ID in DB: " + wid);
            phoenixDAO.addWorkloadId(wid, new Date(), hash);
            workloadHashToIdMap.put(hash, wid);
            log.info("New Workload ID Saved in DB: " + wid);
            System.out.println("New Workload ID Saved in DB: " + wid);
        }

        log.info("Workload ID: " + wid);
        return  wid;
    }



    public int getFileWorkloadID(String filePath){
        String workload = "";
        List<String> lines = getFileLines(filePath);
        if(lines.size()==0){
            log.info("Error: cant assign workflow id to empty workload");
            return -1;
        }

        lines = getWorkloadLines(lines);
        for(String line: lines){
            workload += line;
        }

        return getWorkloadId(workload);

    }


    public int getWorkloadIDFromFileContents(String fileContents){
        String workload = "";
        List<String> lines = Arrays.asList(fileContents.split("\n"));
        if(lines.size()==0){
            log.info("Error: cant assign workflow id to empty workload");
            return -1;
        }

        lines = getWorkloadLines(lines);
        for(String line: lines){
            workload += line;
        }

        return getWorkloadId(workload);

    }





    private List<String> getWorkloadLines(List<String> lines){
        List<String> res = new ArrayList<String>();
        int count = 0;
        for(String line: lines){
            line = line.trim();
            if(line.startsWith("--") || line.isEmpty() || line.startsWith("set ")) {
                count++;
                continue;
            }
            else
                res.add(line);
        }
        log.info("Number of Comments, Set & Empty Lines Discarded: " + count);
        return res;
    }


    private List<String> getFileLines(String filePath){
        BufferedReader br = null;
        List<String> fileLines = new ArrayList<String>();

        try{
            br = new BufferedReader(new FileReader(filePath));
            String line ="";
            while ( (line=br.readLine()) !=null ){
                fileLines.add(line);
            }

        }catch (Exception e){
            log.error(e.getMessage());
        }
        finally {
            try {
                br.close();
            } catch (IOException e) {
                log.error(e.getMessage());
            }
        }

        log.info("Total File Lines: " + fileLines.size());
        return fileLines;

    }



    public long hashCode(String workload){
       // log.info("Finding hash for: " + workload);
        int hash = 0;
        for (int i = 0; i < workload.length(); i++) {
            hash = (hash << 5) - hash + workload.charAt(i);
        }

        log.info("Hash is: " + hash);
        return hash;
    }







}
