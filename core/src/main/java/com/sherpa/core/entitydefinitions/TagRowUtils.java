package com.sherpa.core.entitydefinitions;

import org.apache.commons.lang.StringUtils;

import java.math.BigInteger;

/**
 * Created by akhtar
 */

public class TagRowUtils {

    private TagRow tagRow;
    private Row defaultRow, bestTunedRow;
    private BigInteger learningCost = new BigInteger("0");
    private int bestIterationNo=1;

    private String[] workloads = new String[]{"Terasort", "Sort", "Wordcount", "Kmeans", "Bayes", "Aggregation", "Join", "Scan"};
    private String[] dataProfile = new String[]{"Tiny", "Small", "Large", "Huge", "Gigantic"};
    private String[] candidateSolutions = new String[]{"4", "6", "9", "12"};
    private String[] costFunction = new String[]{"Memory", "CPU", "Latency", "Throughput"};



    private String getMatchingText(String[] list, String text){
        for(String str: list)
            if(StringUtils.containsIgnoreCase(text, str))
                return  str;
        return "";
    }


    public String getWorkloadName(){
        return getMatchingText(workloads, tagRow.getTag());
    }


    public String getDataSize(){
        return getMatchingText(dataProfile, tagRow.getTag());
    }


    public String getCandidateSolutions(){
        return getMatchingText(candidateSolutions, tagRow.getTag());
    }

    public String getCostFunction(){
        return getMatchingText(costFunction, tagRow.getTag());
    }


    public float getTotalTime(){
        long time=0;
        for(Row row: tagRow.getRows())
            time += row.getExecutionTime();

        return ( (float)time / (float) (1000*60)  ) ;
    }


    public int getDefaultTime(){
       return defaultRow.getExecutionTime()/1000;
    }

    public int getBestWallClockTime(){
        return bestTunedRow.getExecutionTime()/1000;
    }


    public float getDefaultMbMin(){
        return Row.getFloatValue(defaultRow.getMemoryCost(), 1000 * 60);
    }

    public float getDefaultCpuMin(){
        return Row.getFloatValue(defaultRow.getCpuCost(), 1000 * 60);
    }

    public float getBestMbMin(){
        return Row.getFloatValue(bestTunedRow.getMemoryCost(), 1000 * 60);
    }

    public float getBestCpuMin(){
        return Row.getFloatValue(bestTunedRow.getCpuCost(), 1000 * 60);
    }





    private void init(){
        String costFunc = getCostFunction();
        setDefault();
        if(costFunc.equalsIgnoreCase("Memory"))
            setMinMemoryCostRow();
        else if(costFunc.equalsIgnoreCase("CPU"))
            setMinCpuCostRow();
        else if(costFunc.equalsIgnoreCase("Latency"))
            setMinLatencyCostRow();
        else if(costFunc.equalsIgnoreCase("Throughput"))
            setMaxThroughputCostRow();
        else
            System.out.println("\n\n ******** Error: Unknown Cost Function: " + costFunc);

    }

    private void setMinMemoryCostRow(){
        int iterationNo=1;
        System.out.println("Finding Min Memory Row ...");
        BigInteger min = new BigInteger(String.valueOf(Long.MAX_VALUE));
        for(Row row: tagRow.getRows()) {
            if (row.getSherpaTuned().equalsIgnoreCase("Yes")) {
                learningCost = learningCost.add(row.getMemoryCost());
                int res= min.compareTo(row.getMemoryCost());
                if(res==1) {
                    bestTunedRow = row;
                    bestIterationNo = iterationNo;
                    min = row.getMemoryCost();
                }
            }
            iterationNo++;
        }
        learningCost = learningCost.subtract(defaultRow.getMemoryCost()).divide(new BigInteger(String.valueOf(1000 * 60)));;
        System.out.println("Min Memory= " + bestTunedRow.getMemoryCost());
    }


    private void setMinCpuCostRow(){
        int iterationNo=1;
        System.out.println("Finding Min Cpu Row ...");
        BigInteger min = new BigInteger(String.valueOf(Long.MAX_VALUE));
        for(Row row: tagRow.getRows()) {
            if (row.getSherpaTuned().equalsIgnoreCase("Yes")) {
                learningCost = learningCost.add(row.getCpuCost());
                int res= min.compareTo(row.getCpuCost());
                if(res==1) {
                    bestIterationNo = iterationNo;
                    bestTunedRow = row;
                    min = row.getCpuCost();
                }
            }
            iterationNo++;
        }
        learningCost = learningCost.subtract(defaultRow.getCpuCost()).divide(new BigInteger(String.valueOf(1000 * 60)));;
        System.out.println("Min Cpu= " + bestTunedRow.getCpuCost());
    }


    private void setMinLatencyCostRow(){
        int iterationNo=1;
        System.out.println("Finding Min Latency Row ...");
        BigInteger min = new BigInteger(String.valueOf(Long.MAX_VALUE));
        for(Row row: tagRow.getRows()) {
            if (row.getSherpaTuned().equalsIgnoreCase("Yes")) {
                learningCost = learningCost.add(row.getLatencyCost());
                int res= min.compareTo(row.getLatencyCost());
                if(res==1) {
                    bestIterationNo = iterationNo;
                    bestTunedRow = row;
                    min = row.getLatencyCost();
                }
            }
            iterationNo++;
        }
        learningCost = learningCost.subtract(defaultRow.getLatencyCost()).divide(new BigInteger(String.valueOf(1000 * 60)));;
        System.out.println("Min Latency= " + bestTunedRow.getLatencyCost());
    }


    private void setMaxThroughputCostRow(){
        int iterationNo=1;
        System.out.println("Finding Max Throughput Row ...");
        BigInteger max = new BigInteger(String.valueOf(Long.MIN_VALUE));
        for(Row row: tagRow.getRows()) {
            if (row.getSherpaTuned().equalsIgnoreCase("Yes")) {
                learningCost = learningCost.add(row.getThroughputCost());
                int res= max.compareTo(row.getThroughputCost());
                if(res==-1) {
                    bestIterationNo = iterationNo;
                    bestTunedRow = row;
                    max = row.getThroughputCost();
                }
            }
            iterationNo++;
        }
        learningCost = learningCost.subtract(defaultRow.getThroughputCost());
        System.out.println("Max Throughput= " + bestTunedRow.getThroughputCost());
    }



    private void setDefault(){
        for(Row row: tagRow.getRows()) {
            if (row.getSherpaTuned().equalsIgnoreCase("No")) {
                defaultRow = row;
                break;
            }
        }
    }



    public TagRowUtils(TagRow tagRow) {
        this.tagRow = tagRow;
        init();
    }

    public TagRow getTagRow() {
        return tagRow;
    }

    public void setTagRow(TagRow tagRow) {
        this.tagRow = tagRow;
    }

    public int getBestIterationNo() {
        return bestIterationNo;
    }

    public void setBestIterationNo(int bestIterationNo) {
        this.bestIterationNo = bestIterationNo;
    }

    public Row getBestTunedRow() {
        return bestTunedRow;
    }

    public void setBestTunedRow(Row bestTunedRow) {
        this.bestTunedRow = bestTunedRow;
    }

    public Row getDefaultRow() {
        return defaultRow;
    }

    public void setDefaultRow(Row defaultRow) {
        this.defaultRow = defaultRow;
    }

    public BigInteger getLearningCost() {
        return learningCost;
    }



    public void setLearningCost(BigInteger learningCost) {
        this.learningCost = learningCost;
    }
}
