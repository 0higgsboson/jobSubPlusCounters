package com.sherpa.custominputformat;

import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.Random;

/**
 * Created by akhtar on 16/08/2015.
 */
public class DummyDataGenerator {

    private String path = "/home/akhtar_mdin/dummydata";
    private final static String DATA_DIR_NAME = "data";
    private final static int NUMBER_OF_FILES = 100;
    private final static int NUMBER_OF_LINES = 10000;
    private final static int WORD_LENGTH = 10;



    private Random random = new Random();


    public static void main(String[] args){
        new DummyDataGenerator().generateDummyData(null);

    }




    public  void generateDummyData(String p){
        if(p!=null && !p.isEmpty())
            path = p;

        if(!path.endsWith("/"))
            path += "/";

        String dir = path + DATA_DIR_NAME;
        File dirFile = new File(dir);
        if(!dirFile.exists())
            dirFile.mkdir();

        for(int i=1; i<=NUMBER_OF_FILES; i++){
            String fileName = dir + "/" +  i +  ".txt";
            generateFile(fileName);
        }


    }


    public void generateFile(String fileName){
        PrintWriter pw = null;
        int n=0;
        Character c;
        try{
            pw = new PrintWriter(new FileWriter(fileName));
            for(int i=0; i<NUMBER_OF_LINES; i++) {
                String str = "";
                int wl = random.nextInt(WORD_LENGTH) +1;
                for(int j=0; j<wl; j++) {
                    n = random.nextInt(26) + 65;
                    c = (char) n;
                    str += c;
                }
                pw.println(str);
            }
            pw.flush();
        }catch (Exception e){
            e.printStackTrace();
        }
        finally {
            pw.close();
        }

    }




}
