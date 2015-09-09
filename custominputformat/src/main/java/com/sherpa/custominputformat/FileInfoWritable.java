package com.sherpa.custominputformat;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.WritableComparable;

/**
 * Created by akhtar on 13/08/2015.
 */
public class FileInfoWritable implements WritableComparable<FileInfoWritable>{

    public long offset;
    public String fileName;



    public FileInfoWritable() {
        super();
    }

    public FileInfoWritable(long offset, String fileName) {
        super();
        this.offset = offset;
        this.fileName = fileName;
    }

    public void readFields(DataInput in) throws IOException {
        this.offset = in.readLong();
        this.fileName = Text.readString(in);
    }

    public void write(DataOutput out) throws IOException {
        out.writeLong(offset);
        Text.writeString(out, fileName);
    }


    @Override
    public boolean equals(Object obj) {
        if(obj instanceof FileInfoWritable) {
            FileInfoWritable that = (FileInfoWritable)obj;
            return this.compareTo(that) == 0;
        }
        return false;
    }
    @Override
    public int hashCode() {

        final int hashPrime = 47;
        int hash = 13;
        hash =   hashPrime* hash + (this.fileName != null ? this.fileName.hashCode() : 0);
        hash =  hashPrime* hash + (int) (this.offset ^ (this.offset >>> 16));

        return hash;
    }


    @Override
    public String toString(){
        return this.fileName+"-"+this.offset;
    }


    public int compareTo(FileInfoWritable o) {
        FileInfoWritable that = (FileInfoWritable)o;

        int f = this.fileName.compareTo(that.fileName);
        if(f == 0) {
            return (int)Math.signum((double)(this.offset - that.offset));
        }
        return f;
    }
}
