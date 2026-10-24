package com.mypad.model;

import java.util.Date;
import org.bson.Document;

/**
 * Model representing a MyPad User account.
 * Supports email + password authentication.
 */
public class User implements java.io.Serializable {

    private static final long serialVersionUID = 1L;

    private String id; // usually same as username or mongo id
    private String email;
    private String username;
    private String passwordHash;
    private String salt;
    private Date createdAt;
    private Date updatedAt;

    public User() {
    }

    public User(String email, String username, String passwordHash, String salt, Date createdAt, Date updatedAt) {
        this.email = email != null ? email.toLowerCase().trim() : "";
        this.username = username != null ? username.toLowerCase().trim() : "";
        this.passwordHash = passwordHash;
        this.salt = salt;
        this.createdAt = createdAt != null ? createdAt : new Date();
        this.updatedAt = updatedAt != null ? updatedAt : new Date();
        this.id = this.username;
    }

    public static User fromDocument(Document doc) {
        if (doc == null) {
            return null;
        }
        User user = new User();
        user.setId(doc.getString("_id"));
        user.setEmail(doc.getString("email"));
        user.setUsername(doc.getString("username"));
        user.setPasswordHash(doc.getString("passwordHash"));
        user.setSalt(doc.getString("salt"));
        user.setCreatedAt(doc.getDate("createdAt"));
        user.setUpdatedAt(doc.getDate("updatedAt"));
        return user;
    }

    public Document toDocument() {
        Document doc = new Document();
        doc.append("_id", username);
        doc.append("email", email);
        doc.append("username", username);
        doc.append("passwordHash", passwordHash);
        doc.append("salt", salt);
        doc.append("createdAt", createdAt != null ? createdAt : new Date());
        doc.append("updatedAt", updatedAt != null ? updatedAt : new Date());
        return doc;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getSalt() {
        return salt;
    }

    public void setSalt(String salt) {
        this.salt = salt;
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
}
