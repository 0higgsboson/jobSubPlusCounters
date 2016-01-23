package com.sherpa.core.entitydefinitions;

import org.apache.commons.lang.StringUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by akhtar
 */

public class TagRow {
    private String tag;
    private List<Row> rows;





    public TagRow() {
        this.rows = new ArrayList<Row>();
    }

    public TagRow(String tag, Row row) {
        this.rows = new ArrayList<Row>();
        this.tag = tag;
        this.rows.add(row);
    }


    public List<Row> getRows() {
        return rows;
    }

    public void setRows(List<Row> rows) {
        this.rows = rows;
    }

    public String getTag() {
        return tag;
    }

    public void setTag(String tag) {
        this.tag = tag;
    }


    public void add(Row row){
        rows.add(row);
    }


}
