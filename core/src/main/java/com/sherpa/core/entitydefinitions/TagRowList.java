package com.sherpa.core.entitydefinitions;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by akhtar
 */
public class TagRowList {
    private Map<String, TagRow> tagRowMap;


    public TagRowList() {
        this.tagRowMap = new HashMap<String, TagRow>();
    }


    public void add(String tag, Row row){
        if(tagRowMap.containsKey(tag))
            tagRowMap.get(tag).add(row);
        else
            tagRowMap.put(tag, new TagRow(tag, row));
    }


    public Map<String, TagRow> getTagRowMap() {
        return tagRowMap;
    }

    public void setTagRowMap(Map<String, TagRow> tagRowMap) {
        this.tagRowMap = tagRowMap;
    }
}
