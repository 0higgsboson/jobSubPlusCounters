package com.sherpa.tunecore.entitydefinitions.job.execution;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

/**
 * Created by akhtar on 10/08/2015.
 */


@Data
@JsonIgnoreProperties(ignoreUnknown = true)


/**
 * This class is a container or top level entity for application status class
 */
public class Application {
    private ApplicationStatus app;

    public ApplicationStatus getApp(){
        return this.app;
    }


}
