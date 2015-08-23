package com.sherpa.core.utils;

import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.dao.WorkloadNameToIdMapper;
import com.sherpa.core.entitydefinitions.WorkloadCounters;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Map;

/**
 * Created by akhtar on 22/08/2015.
 */
public class Driver {
    private static final Logger log = LoggerFactory.getLogger(Driver.class);


    public static void main(String[] args){
        WorkloadCountersManager mgr = new WorkloadCountersManager();
       /* WorkloadCounters wc = new WorkloadCounters();
        wc.setCpu("10");
        wc.setMemory("1G");
        wc.setElapsedTime(90);

        WorkloadCountersManager mgr = new WorkloadCountersManager();
        mgr.saveWorkloadCounters(1, wc);


        wc.setCpu("20");
        wc.setMemory("2G");
        wc.setElapsedTime(20);
        mgr.saveWorkloadCounters(2, wc);



        wc.setCpu("30");
        wc.setMemory("3G");
        wc.setElapsedTime(30);
        mgr.saveWorkloadCounters(3, wc);


        wc = mgr.getWorkloadCounters(2);
        log.info(wc.toString());
*/
        log.info("Printing All Workload Counters");
        List<WorkloadCounters> list = mgr.getAllWorkloadCounters();


        Map<Integer, String> map = WorkloadNameToIdMapper.getWorkloadIdToNameMap();
        for(WorkloadCounters w: list) {
            log.info( map.get(w.getWorkloadId())  + " =>    " + w.toString());
        }
        log.info("Done Testing ...");

    }

}
