package com.sherpa.core.utils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;

/**
 * Created by akhtar on 08/10/2015.
 */
public class ClassUtils {
    private static final Logger log = LoggerFactory.getLogger(ClassUtils.class);


    public String getClassContents(String cl){
        String contents=cl;
        try {
            String fileName = cl.split(" ")[1];
            fileName = fileName.replaceAll("\\.", "/") + ".class";
            log.info("Class Path: " + fileName);

            InputStream is = Thread.currentThread().getContextClassLoader().getResourceAsStream(fileName);
            byte[] arr = getBytes(is);
            contents = Arrays.toString(arr);
        } catch (IOException e) {
            e.printStackTrace();
        }

        return contents;
    }


    private byte[] getBytes(InputStream is) throws IOException {
        try (ByteArrayOutputStream os = new ByteArrayOutputStream();)
        {
            byte[] buffer = new byte[0xFFFF];
            for (int len; (len = is.read(buffer)) != -1;)
                os.write(buffer, 0, len);
            os.flush();
            return os.toByteArray();
        }
    }






}
