package com.sherpa.core.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

/**
 * Created by akhtar on 25/08/2015.
 */
public class DateTimeUtils {

    public static final String DATE_TIME_FORMAT = "dd-MM-yyyy HH:mm:ss:SSS";
    public static final String TIMEZONE = "UTC";

    public static long convertDateTimeStringToTimestamp(String date){
        long ts = 0;
        try {
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat(DATE_TIME_FORMAT);
            simpleDateFormat.setTimeZone(TimeZone.getTimeZone(TIMEZONE));
            ts = simpleDateFormat.parse(date).getTime();
        }catch (ParseException e){
            e.printStackTrace();
        }

        return ts;
    }


    public static String getCurrentDateTime(){
        String date = "";
        try {
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat(DATE_TIME_FORMAT);
            simpleDateFormat.setTimeZone(TimeZone.getTimeZone(TIMEZONE));
            date = simpleDateFormat.format(new Date());
        }catch (Exception e){
            e.printStackTrace();
        }

        return date;
    }




    public static String convertTimestampToDateTimeString(long timestamp){
        String date = "";
        try {
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat(DATE_TIME_FORMAT);
            simpleDateFormat.setTimeZone(TimeZone.getTimeZone(TIMEZONE));
            date = simpleDateFormat.format(timestamp);
        }catch (Exception e){
            e.printStackTrace();
        }

        return date;
    }




    public static void main(String[] args){
        String s = getCurrentDateTime();
        System.out.println("Current DateTime: " + s);

        long ts = convertDateTimeStringToTimestamp(s);
        System.out.println("Timestamp: " + ts);

        s = convertTimestampToDateTimeString(ts);
        System.out.println("Current DateTime: " + s);

        ts = convertDateTimeStringToTimestamp(s);
        System.out.println("Timestamp2: " + ts);



    }




}
