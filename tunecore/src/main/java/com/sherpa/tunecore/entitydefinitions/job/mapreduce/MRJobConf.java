package com.sherpa.tunecore.entitydefinitions.job.mapreduce;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.sherpa.tunecore.metricsextractor.mapreduce.HistoricalJobCounters;
import lombok.Data;
import org.springframework.web.client.RestTemplate;

import java.math.BigInteger;

/**
 * Created by akhtar on 02/12/2015.
 */


@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class MRJobConf {
    private Conf conf;


    public Conf getConf() {
        return conf;
    }

    public void setConf(Conf conf) {
        this.conf = conf;
    }



    public String getPropertyValue(String propertyName){
        for(Property property: conf.getProperty()){
            if(property.getName().equalsIgnoreCase(propertyName))
                return property.getValue();
        }

        return "";
    }




    public static void main(String[] args) throws Exception {
        RestTemplate restTemplate = new RestTemplate();
        //	MRJobCounters c = restTemplate.getForObject(SPI.getJobUri("http://master.c.test-sherpa-1015.internal:19888/ws/v1/history/mapreduce/jobs/", "job_1441908739430_0068"), MRJobCounters.class);
        //	System.out.println(c);

        HistoricalJobCounters h = new HistoricalJobCounters("http://104.197.176.154:19888/ws/v1/history/mapreduce/jobs/");
        MRJobConf counters = h.getJobConf("job_1447318583249_0042");

        System.out.println(counters.getPropertyValue("mapreduce.job.maps"));
        System.out.println(counters.getPropertyValue("mapreduce.job.reduces"));

        System.out.println(counters.getPropertyValue("mapreduce.map.memory.mb"));
        System.out.println(counters.getPropertyValue("mapreduce.reduce.memory.mb"));

        System.out.println(counters.getPropertyValue("mapreduce.map.cpu.vcores"));
        System.out.println(counters.getPropertyValue("mapreduce.reduce.cpu.vcores"));


        /**
         *
         *        "mapreduce_max_split_size:BIGINT",
         "mapreduce_job_reduces:BIGINT",
         "mapreduce_map_memory_mb:BIGINT",
         "mapreduce_reduce_memory_mb:BIGINT",
         "mapreduce_map_cpu_vcores:BIGINT",
         "mapreduce_reduce_cpu_vcores:BIGINT",

         */

    }




}
