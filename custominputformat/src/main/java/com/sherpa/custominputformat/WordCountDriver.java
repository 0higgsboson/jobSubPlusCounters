package com.sherpa.custominputformat;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

/**
 * Created by akhtar on 13/08/2015.
 */
public class WordCountDriver {



    public static void main(String[] args) throws Exception {
        runWordCount(args);
    }



    public static void runWordCount(String[] args) throws Exception {
        Configuration conf = new Configuration();
        Job job = new Job(conf);
        job.setJobName("Small Files Problem");
        job.setJarByClass(WordCountDriver.class);
        FileInputFormat.addInputPath(job, new Path(args[0]));
        job.setInputFormatClass(TextInputFormat.class);
        job.setMapperClass(SimpleMapper.class);
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);
        job.setReducerClass(TestReducer.class);
        //job.setNumReduceTasks(13);
        Path out = new Path(args[1]);
        FileSystem fs = FileSystem.get(conf);
        if( fs.exists(out) )
            fs.delete(out);

        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        job.submit();
        job.waitForCompletion(true);


    }










}
