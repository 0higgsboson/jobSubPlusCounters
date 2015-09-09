package com.sherpa.custominputformat;

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.RecordReader;
import org.apache.hadoop.mapreduce.TaskAttemptContext;
import org.apache.hadoop.mapreduce.lib.input.CombineFileSplit;
import org.apache.hadoop.util.LineReader;


/**
 * Created by akhtar on 13/08/2015.
 */



public class SherpaRecordReader extends RecordReader<FileInfoWritable, Text>{

    private long startOffset;
    private long end;
    private long pos;
    private FileSystem fs;
    private Path path;
    private Path dPath;
    private FileInfoWritable key = new FileInfoWritable();
    private Text value;
    private long rlength;
    private FSDataInputStream fileIn;
    private LineReader reader;


    public SherpaRecordReader(CombineFileSplit split, TaskAttemptContext context, Integer index) throws IOException {
        Configuration currentConf = context.getConfiguration();
        this.path = split.getPath(index);

        fs = this.path.getFileSystem(currentConf);
        this.startOffset = split.getOffset(index);
        this.end = startOffset + split.getLength(index);
        dPath =path;

        boolean skipFirstLine = false;
        fileIn = fs.open(dPath);

        if (startOffset != 0) {
            skipFirstLine = true;
            --startOffset;
            fileIn.seek(startOffset);
        }
        reader = new LineReader(fileIn);
        if (skipFirstLine) {
            startOffset += reader.readLine(new Text(), 0,
                    (int)Math.min((long)Integer.MAX_VALUE, end - startOffset));
        }
        this.pos = startOffset;
    }



    @Override
    public void initialize(InputSplit inputSplit, TaskAttemptContext taskAttemptContext) throws IOException, InterruptedException {
    }

    @Override
    public boolean nextKeyValue() throws IOException, InterruptedException {
        if (key.fileName== null) {
            key = new FileInfoWritable();
            key.fileName = dPath.getName();
        }
        key.offset = pos;
        if (value == null) {
            value = new Text();
        }
        int newSize = 0;
        if (pos < end) {
            newSize = reader.readLine(value);
            pos += newSize;
        }
        if (newSize == 0) {
            key = null;
            value = null;
            return false;
        } else {
            return true;
        }    }

    @Override
    public FileInfoWritable getCurrentKey() throws IOException, InterruptedException {
        return key;
    }

    @Override
    public Text getCurrentValue() throws IOException, InterruptedException {
        return value;
    }

    @Override
    public float getProgress() throws IOException, InterruptedException {
        if (startOffset == end) {
            return 0.0f;
        } else {
            return Math.min(1.0f, (pos - startOffset) / (float)
                    (end - startOffset));
        }    }

    @Override
    public void close() throws IOException {

    }
}
