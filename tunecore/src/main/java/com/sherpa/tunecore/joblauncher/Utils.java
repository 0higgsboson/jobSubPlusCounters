package com.sherpa.tunecore.joblauncher;

import com.google.gson.Gson;
import org.apache.commons.lang.StringEscapeUtils;

import java.math.BigInteger;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by akhtar on 26/10/2015.
 */
public class Utils {

    public static synchronized String toJson(Map<String, String> map){
        return new Gson().toJson(map).toString();
    }



    public static synchronized String toString(Map<String, String> map){
        if(map==null)
            return "";
        StringBuilder builder = new StringBuilder();
        for(Map.Entry<String, String> e: map.entrySet()){
            if(e.getKey().contains("hive.security.authorization.sqlstd.confwhitelist"))
                continue;

            String str = e.getKey() + "=" + e.getValue() ;

            if(str.contains(","))
                continue;

            if(str.contains("\\\\"))
                continue;

            str= str.replaceAll("\"", "");
            str= str.replaceAll("\'", "");


            builder.append(e.getKey()).append("=").append(e.getValue()).append("#");
        }
        return  escapeString(builder.toString());
    }


    public static synchronized String toString2(Map<String, BigInteger> map){
        if(map==null)
            return "";
        StringBuilder builder = new StringBuilder();
        for(Map.Entry<String, BigInteger> e: map.entrySet()){
            builder.append(e.getKey()).append("=").append(e.getValue()).append("#");
        }
        return  builder.toString();
    }


    public static synchronized Map<String, BigInteger>  toMap(String params){
        Map<String, BigInteger> map = new HashMap<String, BigInteger>();

        if(params==null || params.isEmpty())
            return  map;

        System.out.println("\nParsing Parameters: " + params);
        params = params.trim();
        String[]  tok = params.split(" ");
        if(tok==null || tok.length==0)
            return map;

        for(String str: tok){
            String[] keyValue = str.trim().split("=");
            if(keyValue.length==2){
                try {
                    String name = keyValue[0].replaceAll("\\.", "_");
                    map.put(name, new BigInteger(keyValue[1]));
                }catch (Exception e){}
            }
            else{
                //System.out.println("Error: parameter not defined correctly:   Parameter=" +  str + "\t Length: " + keyValue.length + "\t Msg: Length was required to be 2");
            }


        }

        System.out.println("Parsed Parameters: " + map);
        return  map;
    }


    public static synchronized HashMap<String, String>  toStrHashMap(String params){
        HashMap<String, String> map = new HashMap<String, String>();

        if(params==null || params.isEmpty())
            return  map;

        params = params.trim();
        String[]  tok = params.split("#");
        if(tok==null || tok.length==0)
            return map;

        for(String str: tok){
            String[] keyValue = str.trim().split("=");
            if(keyValue.length==2){
                try {
                    map.put( keyValue[0], keyValue[1] );
                }catch (Exception e){}
            }
            else{
                //System.out.println("Error: parameter not defined correctly:   Parameter=" +  str + "\t Length: " + keyValue.length + "\t Msg: Length was required to be 2");
            }


        }
        return  map;
    }



    public static synchronized String convertTimeToString(long ts){
        String dateTimeStr = "";
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date d = new Date();
        d.setTime(ts);
        try{
            dateTimeStr = format.format(d);
        }catch (Exception e){
            e.printStackTrace();
        }

        return dateTimeStr;
    }


    public static synchronized String escapeString(String str){
        String res = StringEscapeUtils.escapeSql(str);
        return res.replaceAll("'", "\\'");
    }



}
