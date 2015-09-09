package com.sherpa.custominputformat;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.JobContext;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.input.CombineFileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.CombineFileRecordReader;
import org.apache.hadoop.mapreduce.lib.input.CombineFileSplit;

import java.io.IOException;

/**
 * Created by akhtar on 13/08/2015.
 */
public class SherpaCombineFileInputFormat extends CombineFileInputFormat<FileInfoWritable, Text> {

    public SherpaCombineFileInputFormat(){
        super();
    }

    @Override
    public RecordReader<FileInfoWritable, Text> createRecordReader(InputSplit inputSplit, TaskAttemptContext taskAttemptContext) throws IOException {
        return new CombineFileRecordReader<FileInfoWritable, Text>((CombineFileSplit)inputSplit, taskAttemptContext, SherpaRecordReader.class);
    }


    @Override
    protected boolean isSplitable(JobContext context, Path file) {
        return super.isSplitable(context, file);
    }
}
