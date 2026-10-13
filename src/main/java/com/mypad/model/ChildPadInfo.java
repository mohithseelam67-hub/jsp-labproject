package com.mypad.model;

import java.util.Date;

/**
 * Model representing an immediate child pad or directory entry.
 */
public class ChildPadInfo {

    private String name;
    private String path;
    private boolean isPad;
    private Date updatedAt;
    private Integer version;

    public ChildPadInfo() {
    }

    public ChildPadInfo(String name, String path, boolean isPad, Date updatedAt, Integer version) {
        this.name = name;
        this.path = path;
        this.isPad = isPad;
        this.updatedAt = updatedAt;
        this.version = version;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public boolean isPad() {
        return isPad;
    }

    public void setPad(boolean pad) {
        isPad = pad;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Integer getVersion() {
        return version;
    }

    public void setVersion(Integer version) {
        this.version = version;
    }
}
