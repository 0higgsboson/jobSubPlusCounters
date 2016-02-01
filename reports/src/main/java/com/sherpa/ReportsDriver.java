package com.sherpa;

import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.entitydefinitions.TagRowList;

/**
 * Created by akhtar
 */


public class ReportsDriver {

    public void updateGoogleSpreadSheet(String whereClause){
        System.out.println("Running Reports Driver with where condition : " + whereClause);

        WorkloadCountersManager mgr = new WorkloadCountersManager();
        TagRowList tagRowList = mgr.getTagsData(whereClause);

        System.out.println("Total Tags To Process : " + tagRowList.getTagRowMap().size());

        SpreadSheetManager spreadSheetManager = new SpreadSheetManager();
        spreadSheetManager.addStatsEntries(tagRowList);
        mgr.close();
    }




    //Optionally takes tag name to filter results
    public static void main(String[] args){
        String where="";
        if(args!=null && args.length==1){
           where = "tag='"+args[0]+"'";
        }

        //String where = "tag='2016-01-19_aggregation_Memory_small_CS4_LW0.2'";
        ReportsDriver reportsDriver = new ReportsDriver();
        reportsDriver.updateGoogleSpreadSheet(where);
    }


}
