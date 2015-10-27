package com.sherpa.importexport;

import com.sherpa.core.bl.WorkloadCountersManager;
import com.sherpa.core.utils.EmailUtils;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by akhtar on 28/10/2015.
 */
public class ImportExportDriver {


    public static void main(String[] args){

        if(args.length!=2){
            System.out.println("Usage: outputDirName dateTime");
            System.exit(1);
        }

        String dirPath = args[0];
        if(!dirPath.endsWith(File.separator))
            dirPath = dirPath + File.separator;

        File file = new File(dirPath);
        if(!file.exists()){
            file.mkdirs();
            System.out.println("Created output dir ..." + dirPath);
        }

        dirPath = new PhoenixTableExport().run(dirPath, args[1]);
        new PhoenixTableImport().run(dirPath, args[1]);


    }




}
