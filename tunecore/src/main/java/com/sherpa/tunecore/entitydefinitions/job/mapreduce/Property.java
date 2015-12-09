package com.sherpa.tunecore.entitydefinitions.job.mapreduce;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

/**
 * Created by akhtar on 02/12/2015.
 */


@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class Property {
    private String name;
    private String value;


    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}
