package com.sherpa.custominputformat;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;
import java.util.Iterator;

/**
 * Created by akhtar on 16/08/2015.
 */
public class TestReducer extends Reducer<Text, IntWritable, Text, IntWritable>{


    @Override
    protected void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
        super.reduce(key, values, context);

        int sum=0;
        Iterator<IntWritable> iterator =  values.iterator();
        while(iterator.hasNext()){
            sum++;
        }

        context.write(new Text(key.toString()), new IntWritable(sum));
    }
}
