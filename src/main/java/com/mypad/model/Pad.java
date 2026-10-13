package com.mypad.model;

import java.util.Date;
import org.bson.Document;

/**
 * Model representing a MyPad document.
 */
public class Pad {

    private String path;
    private String content;
    private Date createdAt;
    private Date updatedAt;
    private int version;
    private String parentPath;

    public Pad() {
    }

    public Pad(String path, String content, Date createdAt, Date updatedAt, int version, String parentPath) {
        this.path = path;
        this.content = content != null ? content : "";
        this.createdAt = createdAt != null ? createdAt : new Date();
        this.updatedAt = updatedAt != null ? updatedAt : new Date();
        this.version = version;
        this.parentPath = parentPath;
    }

    public static Pad fromDocument(Document doc) {
        if (doc == null) {
            return null;
        }
        Pad pad = new Pad();
        pad.setPath(doc.getString("_id"));
        pad.setContent(doc.getString("content"));
        pad.setCreatedAt(doc.getDate("createdAt"));
        pad.setUpdatedAt(doc.getDate("updatedAt"));
        Integer ver = doc.getInteger("version");
        pad.setVersion(ver != null ? ver : 1);
        pad.setParentPath(doc.getString("parentPath"));
        return pad;
    }

    public Document toDocument() {
        Document doc = new Document();
        doc.append("_id", path);
        doc.append("content", content != null ? content : "");
        doc.append("createdAt", createdAt != null ? createdAt : new Date());
        doc.append("updatedAt", updatedAt != null ? updatedAt : new Date());
        doc.append("version", version);
        doc.append("parentPath", parentPath);
        return doc;
    }

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public String getContent() {
        return content != null ? content : "";
    }

    public void setContent(String content) {
        this.content = content != null ? content : "";
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public int getVersion() {
        return version;
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public String getParentPath() {
        return parentPath;
    }

    public void setParentPath(String parentPath) {
        this.parentPath = parentPath;
    }
}
