package com.sherpa.core.dao;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by akhtar on 22/08/2015.
 */
public class WorkloadNameToIdMapper {

    public static final String MR_SMALL     = "MR_Small";
    public static final String MR_NORMAL    = "MR_Normal";
    public static final String MR_LARGE     = "MR_Large";

    public static final String HIVE_SMALL     = "Hive_Small";
    public static final String HIVE_NORMAL    = "Hive_Normal";
    public static final String HIVE_LARGE     = "Hive_Large";




    public static Map<String, Integer> getWorkloadNameToIdMap(){
        Map<String, Integer> map = new HashMap<String, Integer>();
        map.put(MR_SMALL, 1);
        map.put(MR_NORMAL, 2);
        map.put(MR_LARGE, 3);
        map.put(HIVE_SMALL, 4);
        map.put(HIVE_NORMAL, 5);
        map.put(HIVE_LARGE, 6);
        return map;
    }




    public static Map<Integer, String> getWorkloadIdToNameMap(){
        Map<Integer, String> map = new HashMap<Integer, String>();
        map.put(1, MR_SMALL);
        map.put(2, MR_NORMAL);
        map.put(3, MR_LARGE);
        map.put(4, HIVE_SMALL);
        map.put(5, HIVE_NORMAL);
        map.put(6, HIVE_LARGE);

        return map;
    }



}
