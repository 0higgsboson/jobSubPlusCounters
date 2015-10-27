package com.sherpa.custominputformat;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

/**
 * Created by akhtar on 13/08/2015.
 */
public class CombineInputFormatWordCountDriver extends Configured implements Tool{



    public static void main(String[] args) throws Exception {
        int res = ToolRunner.run(new Configuration(), new CombineInputFormatWordCountDriver(), args);
        System.exit(res);
    }


    @Override
    public int run(String[] args) throws Exception {

        System.out.println("\n\n Custom File Format Driver ...");

        Configuration conf = this.getConf();
        Job job = new Job(conf);
        job.setJobName("Small Files Demo");
        job.setJarByClass(CombineInputFormatWordCountDriver.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));

        job.setInputFormatClass(SherpaCombineFileInputFormat.class);

        job.setMapperClass(SmallFilesMapper.class);
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);

        job.setReducerClass(TestReducer.class);
        job.setCombinerClass(TestReducer.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        job.setNumReduceTasks(1);

        Path out = new Path(args[1]);
        FileSystem fs = FileSystem.get(conf);
        if( fs.exists(out) )
            fs.delete(out);

        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        job.submit();
        return job.waitForCompletion(true) ? 0 : 1;

    }








}
