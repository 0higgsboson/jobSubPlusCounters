package com.sherpa.custominputformat;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import java.util.Iterator;
import java.util.Map;

/**
 * Created by akhtar on 13/08/2015.
 */
public class WordCountDriver{

    public static void main(String[] rawArgs) throws Exception {
        GenericOptionsParser parser = new GenericOptionsParser(rawArgs);
        Configuration conf = parser.getConfiguration();
        String[] args = parser.getRemainingArgs();


        System.out.println("PSManaged in Driver : " + conf.get("PSManaged"));
        Job job = new Job(conf);
        job.setJobName("Sherpa Word Count");
        job.setJarByClass(WordCountDriver.class);
        FileInputFormat.addInputPath(job, new Path(args[0]));
        job.setInputFormatClass(TextInputFormat.class);
        job.setMapperClass(SimpleMapper.class);
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);
        job.setReducerClass(TestReducer.class);
        job.setNumReduceTasks(4);
        Path out = new Path(args[1]);
        FileSystem fs = FileSystem.get(conf);
        if( fs.exists(out) )
            fs.delete(out);

        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        job.submit();

        job.waitForCompletion(true);


    }









/*

    public static void main(String[] args) throws Exception {
        int res = ToolRunner.run(new Configuration(), new WordCountDriver(), args);
        System.exit(res);
    }

    @Override
    public int run(String[] args) throws Exception {
        Configuration conf = this.getConf();

      */
/*  Iterator<Map.Entry<String, String>> iterator = conf.iterator();
        while(iterator.hasNext()){
            Map.Entry<String, String> e = iterator.next();
            System.out.println( e.getKey() + "=" + e.getValue() );
        }*//*






        System.out.println("PSManaged in Driver : " + conf.get("PSManaged"));
        Job job = new Job(conf);
        job.setJobName("Sherpa Word Count");
        job.setJarByClass(WordCountDriver.class);
        FileInputFormat.addInputPath(job, new Path(args[0]));
        job.setInputFormatClass(TextInputFormat.class);
        job.setMapperClass(SimpleMapper.class);
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);
        job.setReducerClass(TestReducer.class);
        job.setNumReduceTasks(4);
        Path out = new Path(args[1]);
        FileSystem fs = FileSystem.get(conf);
        if( fs.exists(out) )
            fs.delete(out);

        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        job.submit();

        return job.waitForCompletion(true) ? 0 : 1;

    }

*/


}
