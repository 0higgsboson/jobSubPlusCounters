package com.sherpa.custominputformat;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;
import java.util.StringTokenizer;

/**
 * Created by akhtar on 16/08/2015.
 */




public class SmallFilesMapper extends Mapper<FileInfoWritable, Text, Text, IntWritable>{

    private Text txt = new Text();
    private IntWritable count = new IntWritable(1);


    public void map (FileInfoWritable key, Text val, Context context) throws IOException, InterruptedException{

        System.out.println(key.toString());
        StringTokenizer st = new StringTokenizer(val.toString());
        while (st.hasMoreTokens()){
            txt.set(st.nextToken());
            context.write(txt, count);
        }
    }
}









