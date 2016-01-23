package com.sherpa;

import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.gdata.client.GoogleAuthTokenFactory;
import com.google.gdata.client.Service;
import com.google.gdata.client.spreadsheet.*;
import com.google.gdata.data.PlainTextConstruct;
import com.google.gdata.data.spreadsheet.*;
import com.google.gdata.util.*;
import com.google.gdata.client.http.HttpGDataRequest.Factory;
import com.sherpa.core.entitydefinitions.Row;
import com.sherpa.core.entitydefinitions.TagRow;
import com.sherpa.core.entitydefinitions.TagRowList;
import com.sherpa.core.entitydefinitions.TagRowUtils;


import com.google.api.services.drive.DriveScopes;
import com.google.api.services.drive.model.*;
import com.google.api.services.drive.Drive;


import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigInteger;
import java.net.*;
import java.util.*;



/**
 *
 * @author akhtar
 */


public class SpreadSheetManager {
    public static final String CLIENT_ID     = "706514641456-7djbk7m4r21jninl7uiho703c2a7nu8o.apps.googleusercontent.com";
    public static final String CLIENT_SECRET = "eLNV7ZKa-L3bP1UYYRSB2D5N";
    public static final String SCOPE = "https://spreadsheets.google.com/feeds https://docs.google.com/feeds";
    public static final String REDIRECT_URI = "urn:ietf:wg:oauth:2.0:oob";

    private SpreadsheetService service;
    private Drive drive;
    private Credential credential;


    // Define the URL to request.  This should never change.
    private static final String SPREADSHEET_FEED_URL = "https://spreadsheets.google.com/feeds/spreadsheets/private/full";
    private static final String TEST_PLAN_SPREADSHEET_NAME = "Test Plan";

    public SpreadSheetManager() {
        try {
            credential =  OAuthHelper.authorize();
            service =   new SpreadsheetService("Sherpa_App");
            service.setOAuth2Credentials(credential);
            drive = GoogleDriveHelper.getDriveService(credential);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    private List<SpreadsheetEntry> getSpreadsheetFeed(){
        URL SPREADSHEET_FEED_URL = null;
        List<SpreadsheetEntry> spreadsheets = null;
        try {
            SPREADSHEET_FEED_URL = new URL(
                    "https://spreadsheets.google.com/feeds/spreadsheets/private/full");
            SpreadsheetFeed feed = service.getFeed(SPREADSHEET_FEED_URL, SpreadsheetFeed.class);
            spreadsheets = feed.getEntries();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return spreadsheets;
    }


    private WorksheetEntry getWorksheetByName(String spreadsheetName){
        SpreadsheetEntry sheet=null;
        List<SpreadsheetEntry> sheets = getSpreadsheetFeed();
        for (SpreadsheetEntry spreadsheet : sheets) {
            if(spreadsheet.getTitle().getPlainText().equalsIgnoreCase(spreadsheetName)) {
                sheet = spreadsheet;
                break;
            }
        }

        if(sheet==null){
            System.out.println("\n\n Error: Could not find " + spreadsheetName +  " ReportsDriver Plan SpreadSheet");
            return null;
        }

        WorksheetFeed worksheetFeed =null;
        try {
            worksheetFeed   = service.getFeed( sheet.getWorksheetFeedUrl(), WorksheetFeed.class);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ServiceException e) {
            e.printStackTrace();
        }

        if(worksheetFeed==null){
            System.out.println("\n\n Error: Could not find Worksheet Feed in " + spreadsheetName);
            return null;
        }


        List<WorksheetEntry> worksheets = worksheetFeed.getEntries();
       /* if(worksheets.size()==0){

        }
       */
        WorksheetEntry worksheet = worksheets.get(0);
        return worksheet;
    }


    public void addStatsEntries(TagRowList tagRowList){
        for(Map.Entry<String, TagRow> e: tagRowList.getTagRowMap().entrySet()) {

            System.out.println("\n\n Creating/Updating Sheets For Tag: " + e.getKey());
            System.out.println("******************************************************************************");
            addStatsEntry(e.getValue());
            createDataSheet(e.getValue());
        }
    }


    private void writeToFile(String fileName, String contents){
        File file = null;
        PrintWriter pw = null;
        try {
            file = new File(fileName);
            System.out.println("Creating temp file: " + file.getAbsolutePath());
            pw = new PrintWriter(new FileWriter(fileName));
            pw.println(contents);
            pw.flush();
        }catch (Exception e){
            e.printStackTrace();
        }
        finally {
            if(pw!=null){
                pw.close();
            }
        }
    }


    private void deleteFile(String fileName){
        File file = null;
        try {
            file = new File(fileName);
            System.out.println("Deleting temp file: " + file.getAbsolutePath());
            if(file.exists()){
                file.delete();
            }
        }catch (Exception e){
            e.printStackTrace();
        }
    }


    public void createDataSheet(TagRow tagRow){
        System.out.println("Creating Data Spreadsheet for Tag: " + tagRow.getTag());
        ListFeed listFeed = null;
        try {

             StringBuilder stringBuilder = new StringBuilder();

            stringBuilder.append("Tag").append(",")
                    .append("Execution-Time").append(",")
                    .append("Sherpa-Tuned").append(",")
                    .append("No-Reducers").append(",")
                    .append("Map-Memory").append(",")
                    .append("Reduce-Memory").append(",")
                    .append("Map-Cores").append(",")
                    .append("Reduce-Cores").append(",")
                    .append("Max-Split-Size").append(",")
                    .append("Map-Mb-Millis").append(",")
                    .append("Reduce-Mb-Millis").append(",")
                    .append("Map-Cpu-MilliSeconds").append(",")
                    .append("Reduce-Cpu-MilliSeconds").append(",")
                    .append("HDFS-Bytes-Read").append(",")
                    .append("HDFS-Bytes-Written").append(",")
                    .append("Map-Vcores-Millis").append(",")
                    .append("Reduce-Vcores-Millis").append(",")
                    .append("Map-Millis").append(",")
                    .append("Reduce-Millis").append(",")
                    .append("Map-Physical-Memory-Bytes").append(",")
                    .append("Reduce-Physical-Memory-Bytes");

            for(Row row: tagRow.getRows()){
                stringBuilder.append("\n");
                stringBuilder.append(tagRow.getTag()).append(",")
                        .append(row.getExecutionTime()).append(",")
                        .append(row.getSherpaTuned()).append(",")
                        .append(row.getNoReducers()).append(",")
                        .append(row.getMapMemory()).append(",")
                        .append(row.getReduceMemory()).append(",")
                        .append(row.getMapCores()).append(",")
                        .append(row.getReduceCores()).append(",")
                        .append(row.getMaxSplitSize()).append(",")
                        .append(row.getMapMbMillis()).append(",")
                        .append(row.getReduceMbMillis()).append(",")
                        .append(row.getMapCpuMilliSeconds()).append(",")
                        .append(row.getReduceCpuMilliSeconds()).append(",")
                        .append(row.getHdfsBytesRead()).append(",")
                        .append(row.getHdfsBytesWritten()).append(",")
                        .append(row.getMapVcoresMillis()).append(",")
                        .append(row.getReduceVcoresMillis()).append(",")
                        .append(row.getMapMillis()).append(",")
                        .append(row.getReduceMillis()).append(",")
                        .append(row.getMapPhysicalMemoryBytes()).append(",")
                        .append(row.getReducePhysicalMemoryBytes()).append(",");
            }

            String ext = ".csv";
            Date date = new Date();
            String spreadsheetName = tagRow.getTag() + "_" + date.toString();
            String fileName = spreadsheetName + ext;

            writeToFile(fileName, stringBuilder.toString());
            GoogleDriveHelper.uploadFile(drive, spreadsheetName, fileName);
            deleteFile(fileName);

            System.out.println("Successfully Created Spreadsheet for Tag: " + tagRow.getTag());
        } catch (Exception e) {
            e.printStackTrace();
        }

    }




    public void addStatsEntry(TagRow tagRow){
        System.out.println("Adding Stats Entry for Tag: " + tagRow.getTag());
        ListFeed listFeed = null;
        try {
            TagRowUtils utils = new TagRowUtils(tagRow);
            WorksheetEntry worksheet = getWorksheetByName(TEST_PLAN_SPREADSHEET_NAME);
            URL listFeedUrl = worksheet.getListFeedUrl();
            listFeed = service.getFeed(listFeedUrl, ListFeed.class);


            ListEntry row = new ListEntry();
            row.getCustomElements().setValueLocal("Workload", utils.getWorkloadName());
            row.getCustomElements().setValueLocal("Tag", tagRow.getTag());
            row.getCustomElements().setValueLocal("Data-Size", utils.getDataSize());
            row.getCustomElements().setValueLocal("Sol-Candidates", utils.getCandidateSolutions());

            row.getCustomElements().setValueLocal("Cost-Func", utils.getCostFunction());
            row.getCustomElements().setValueLocal("Total-Time-Mins", String.valueOf(utils.getTotalTime()));
            row.getCustomElements().setValueLocal("Default-Latency-Sec", String.valueOf(utils.getDefaultTime()));
            row.getCustomElements().setValueLocal("Default-MB-Min", String.valueOf(utils.getDefaultMbMin()));
            row.getCustomElements().setValueLocal("Default-CPU-Min", String.valueOf(utils.getDefaultCpuMin()));
            row.getCustomElements().setValueLocal("Best-Wall-Clock-Time-Sec", String.valueOf(utils.getBestWallClockTime()));
            row.getCustomElements().setValueLocal("Best-MB-Min", String.valueOf(utils.getBestMbMin()));
            row.getCustomElements().setValueLocal("Best-CPU-Min", String.valueOf(utils.getBestCpuMin()));
            row.getCustomElements().setValueLocal("Learning-Cost", String.valueOf(utils.getLearningCost()));
            row.getCustomElements().setValueLocal("Best-Iteration-No", String.valueOf(utils.getBestIterationNo()));

            Row paramRow = utils.getDefaultRow();
            row.getCustomElements().setValueLocal("Def-Split-Size-Mb", String.valueOf(paramRow.getMaxSplitSize()));
            row.getCustomElements().setValueLocal("Def-No-Reducers", String.valueOf(paramRow.getNoReducers()));
            row.getCustomElements().setValueLocal("Def-Map-Mem-MB", String.valueOf(paramRow.getMapMemory()));
            row.getCustomElements().setValueLocal("Def-Red-Mem-MB", String.valueOf(paramRow.getReduceMemory()));
            row.getCustomElements().setValueLocal("Def-Map-CPU", String.valueOf(paramRow.getMapCores()));
            row.getCustomElements().setValueLocal("Def-Red-CPU", String.valueOf(paramRow.getReduceCores()));
            paramRow = utils.getBestTunedRow();
            row.getCustomElements().setValueLocal("Best-Split-Size-MB", String.valueOf(paramRow.getMaxSplitSizeInMb()));
            row.getCustomElements().setValueLocal("Best-No-Reducers", String.valueOf(paramRow.getNoReducers()));
            row.getCustomElements().setValueLocal("Best-Map-Mem-MB-Min", String.valueOf(paramRow.getMapMbMin()));
            row.getCustomElements().setValueLocal("Best-Red-Mem-MB-Min", String.valueOf(paramRow.getReduceMbMin()));
            row.getCustomElements().setValueLocal("Best-Map-CPU-Min", String.valueOf(paramRow.getMapCpuMin()));
            row.getCustomElements().setValueLocal("Best-Red-CPU-Min", String.valueOf(paramRow.getReduceCpuMin()));

            row = service.insert(listFeedUrl, row);
            System.out.println("Successfully Added Stats Entry for Tag: " + tagRow.getTag());

        } catch (IOException e) {
            e.printStackTrace();
        } catch (ServiceException e) {
            e.printStackTrace();
        }








    }



/*
    public static void main(String[] args)
            throws AuthenticationException, MalformedURLException, IOException, ServiceException {

        Credential credential =  OAuthHelper.authorize();

        SpreadsheetService service =   new SpreadsheetService("App");
        service.setOAuth2Credentials(credential);


        // Define the URL to request.  This should never change.
        URL SPREADSHEET_FEED_URL = new URL(
                "https://spreadsheets.google.com/feeds/spreadsheets/private/full");

        // Make a request to the API and get all spreadsheets.
        SpreadsheetFeed feed = service.getFeed(SPREADSHEET_FEED_URL, SpreadsheetFeed.class);
        List<SpreadsheetEntry> spreadsheets = feed.getEntries();

        // Iterate through all of the spreadsheets returned
        for (SpreadsheetEntry spreadsheet : spreadsheets) {
            //             Print the title of this spreadsheet to the screen;
            System.out.println("ID: " + spreadsheet.getId());
            System.out.println(spreadsheet.getTitle().getPlainText());
        }

        if (spreadsheets.size() == 0) {
            System.out.println("No spreadhsheet found ...");
        }



        SpreadsheetEntry spreadsheet = spreadsheets.get(0);
        //        System.out.println(spreadsheet.getTitle().getPlainText());


        System.out.println("SpreadSheet: " +spreadsheet.getTitle().getPlainText());

        WorksheetFeed worksheetFeed = service.getFeed(
                spreadsheet.getWorksheetFeedUrl(), WorksheetFeed.class);
        List<WorksheetEntry> worksheets = worksheetFeed.getEntries();
        WorksheetEntry worksheet = worksheets.get(0);

        // Fetch the list feed of the worksheet.
        URL listFeedUrl = worksheet.getListFeedUrl();
        ListFeed listFeed = service.getFeed(listFeedUrl, ListFeed.class);

        for (ListEntry row : listFeed.getEntries()) {
            // Print the first column's cell value
            System.out.print(row.getTitle().getPlainText() + "\t");
            // Iterate over the remaining columns, and print each cell value
            for (String tag : row.getCustomElements().getTags()) {
                System.out.print(row.getCustomElements().getValue(tag) + "\t");
            }
            System.out.println();
        }


        // Create a local representation of the new row.
        ListEntry row = new ListEntry();
        row.getCustomElements().setValueLocal("Data-Size", "r");
        row.getCustomElements().setValueLocal("A", "s");


        // Send the new row to the API for insertion.
        row = service.insert(listFeedUrl, row);



        //        // Create a local representation of the new worksheet.
       // WorksheetEntry worksheet = new WorksheetEntry();
        *//*worksheet.setTitle(new PlainTextConstruct("New Worksheet"));
        worksheet.setRowCount(5);
        worksheet.setColCount(1);

        // Send the local representation of the worksheet to the API for
        // creation.  The URL to use here is the worksheet feed URL of our
        // spreadsheet.
        URL worksheetFeedUrl = spreadsheet.getWorksheetFeedUrl();
        WorksheetEntry insert = service.insert(worksheetFeedUrl, worksheet);

        *//*


    }*/




}