package com.mypad.config;

import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import org.bson.Document;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.IndexOptions;
import com.mongodb.client.model.Indexes;

/**
 * Manages the lifecycle of shared MongoDB resources with the Servlet container.
 * Creates necessary indexes for both pads and user collections.
 */
@WebListener
public class MongoContextListener implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(MongoContextListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("MyPad web application starting. Initializing MongoDB connection & indexes...");
        try {
            MongoDatabase db = MongoConfig.getDatabase();
            
            // 1. Pads collection indexes
            MongoCollection<Document> padsCollection = db.getCollection(MongoConfig.getPadsCollectionName());
            padsCollection.createIndex(
                    Indexes.ascending("parentPath"),
                    new IndexOptions().name("idx_parentPath")
            );
            padsCollection.createIndex(
                    Indexes.descending("updatedAt"),
                    new IndexOptions().name("idx_updatedAt")
            );
            padsCollection.createIndex(
                    Indexes.ascending("ownerUsername"),
                    new IndexOptions().name("idx_ownerUsername")
            );
            padsCollection.createIndex(
                    Indexes.ascending("visibility"),
                    new IndexOptions().name("idx_visibility")
            );

            // 2. Users collection indexes (email unique, username unique)
            MongoCollection<Document> usersCollection = db.getCollection("users");
            usersCollection.createIndex(
                    Indexes.ascending("username"),
                    new IndexOptions().unique(true).name("idx_user_username")
            );
            usersCollection.createIndex(
                    Indexes.ascending("email"),
                    new IndexOptions().unique(true).name("idx_user_email")
            );

            LOGGER.info("MongoDB initialized and indexes verified for pads & users.");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed during MongoDB initialization in ContextListener", e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOGGER.info("MyPad web application stopping. Tearing down MongoDB resources...");
        try {
            MongoConfig.close();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error while closing MongoDB resources", e);
        }
    }
}
