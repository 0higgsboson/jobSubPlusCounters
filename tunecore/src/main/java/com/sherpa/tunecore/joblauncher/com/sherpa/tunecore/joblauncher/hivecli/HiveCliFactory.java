package com.sherpa.tunecore.joblauncher.com.sherpa.tunecore.joblauncher.hivecli;

/**
 * Created by akhtar on 09/09/2015.
 */
public class HiveCliFactory {
    private static HiveCliJobExecutor hiveCliJobExecutor = null;


    public static HiveCliJobExecutor getHiveCliJobExecutorInstance(String fileContents, String rmUrl, String historyServer, int pollInterval, String params){
        if(hiveCliJobExecutor==null)
            hiveCliJobExecutor = new HiveCliJobExecutor(fileContents, rmUrl, historyServer, pollInterval, params);

        return  hiveCliJobExecutor;
    }


    public static HiveCliJobExecutor getHiveCliJobExecutorInstance(){
        return  hiveCliJobExecutor;
    }




}
