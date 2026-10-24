package com.mypad.model;

import java.util.Date;
import org.bson.Document;

/**
 * Model representing a MyPad document.
 * Includes optional ownership, visibility, and custom theme.
 */
public class Pad {

    private String path;
    private String content;
    private Date createdAt;
    private Date updatedAt;
    private int version;
    private String parentPath;
    private String ownerUsername;
    private String visibility; // "public", "private", "read-only"
    private String theme;      // "light", "dark"

    public Pad() {
        this.visibility = "public";
        this.theme = "light";
    }

    public Pad(String path, String content, Date createdAt, Date updatedAt, int version, String parentPath) {
        this(path, content, createdAt, updatedAt, version, parentPath, null, "public", "light");
    }

    public Pad(String path, String content, Date createdAt, Date updatedAt, int version, String parentPath,
               String ownerUsername, String visibility, String theme) {
        this.path = path;
        this.content = content != null ? content : "";
        this.createdAt = createdAt != null ? createdAt : new Date();
        this.updatedAt = updatedAt != null ? updatedAt : new Date();
        this.version = version;
        this.parentPath = parentPath;
        this.ownerUsername = ownerUsername;
        this.visibility = visibility != null ? visibility : "public";
        this.theme = theme != null ? theme : "light";
    }

    public static Pad fromDocument(Document doc) {
        if (doc == null) {
            return null;
        }
        Pad pad = new Pad();
        String path = doc.getString("_id");
        pad.setPath(path);
        pad.setContent(doc.getString("content"));
        pad.setCreatedAt(doc.getDate("createdAt"));
        pad.setUpdatedAt(doc.getDate("updatedAt"));
        Integer ver = doc.getInteger("version");
        pad.setVersion(ver != null ? ver : 1);
        pad.setParentPath(doc.getString("parentPath"));

        String owner = doc.getString("ownerUsername");
        if ((owner == null || owner.trim().isEmpty()) && path != null && path.startsWith("/@")) {
            int secondSlash = path.indexOf('/', 2);
            owner = secondSlash > 2 ? path.substring(2, secondSlash) : path.substring(2);
        }
        pad.setOwnerUsername(owner);

        String vis = doc.getString("visibility");
        // Profile-created pads (or pads with an owner) are read-only for other visitors
        if (owner != null && !owner.trim().isEmpty()) {
            if (vis == null || "public".equalsIgnoreCase(vis)) {
                vis = "read-only";
            }
        }
        pad.setVisibility(vis != null ? vis : "public");

        String th = doc.getString("theme");
        pad.setTheme(th != null ? th : "light");
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
        if (ownerUsername != null && !ownerUsername.trim().isEmpty()) {
            doc.append("ownerUsername", ownerUsername.trim().toLowerCase());
        }
        doc.append("visibility", visibility != null ? visibility : "public");
        doc.append("theme", theme != null ? theme : "light");
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

    public String getOwnerUsername() {
        return ownerUsername;
    }

    public void setOwnerUsername(String ownerUsername) {
        this.ownerUsername = ownerUsername;
    }

    public String getVisibility() {
        return visibility;
    }

    public void setVisibility(String visibility) {
        this.visibility = visibility;
    }

    public String getTheme() {
        return theme;
    }

    public void setTheme(String theme) {
        this.theme = theme;
    }

    public int getWordCount() {
        if (content == null || content.trim().isEmpty()) {
            return 0;
        }
        String trimmed = content.trim();
        String[] words = trimmed.split("\\s+");
        return words.length;
    }
}
