package com.sherpa.core.bl;

import com.sherpa.core.dao.WorkloadCountersPhoenixDAO;
import com.sherpa.core.entitydefinitions.WorkloadIdDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.*;

/**
 * Created by akhtar on 07/09/2015.
 */


public class WorkloadIdHelper {


    public static synchronized  String getSha1Hash(String workload)  {
        MessageDigest mDigest = null;
        try {
            mDigest = MessageDigest.getInstance("SHA1");
        }catch (NoSuchAlgorithmException e){
            e.printStackTrace();
        }

        byte[] result = mDigest.digest(workload.getBytes());
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < result.length; i++) {
            sb.append(Integer.toString((result[i] & 0xff) + 0x100, 16).substring(1));
            }

        return sb.toString();
    }




}
