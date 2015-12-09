package com.sherpa.tunecore.entitydefinitions.job.mapreduce;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.util.List;

/**
 * Created by akhtar on 02/12/2015.
 */


@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class Conf {

    private List<Property> property;


    public List<Property> getProperty() {
        return property;
    }

    public void setProperty(List<Property> property) {
        this.property = property;
    }
}
