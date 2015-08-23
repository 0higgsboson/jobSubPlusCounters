package com.sherpa.tunecore.entitydefinitions.job.execution;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

/**
 * Created by akhtar on 10/08/2015.
 */


@Data
@JsonIgnoreProperties(ignoreUnknown = true)

/**
 * Contains necessary fields to track the status of a running or stopped application
 */

public class ApplicationStatus {
    // application id
    private String id;
    // application name
    private String name;
    // application state, running, failed etc
    private String state;
    // final state of application once its finished i.e. succeeded or failed
    private String finalStatus;
    // number of milli seconds took to complete job or job finish time
    private String elapsedTime;


    public String getName() {
        return name;
    }

    public String getId() {
        return id;
    }

    public String getState() {
        return state;
    }

    public String getFinalStatus() {
        return finalStatus;
    }


    public void setId(String id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setState(String state) {
        this.state = state;
    }

    public void setFinalStatus(String finalStatus) {
        this.finalStatus = finalStatus;
    }


    public String getElapsedTime() {
        return elapsedTime;
    }

    public void setElapsedTime(String elapsedTime) {
        this.elapsedTime = elapsedTime;
    }
}
