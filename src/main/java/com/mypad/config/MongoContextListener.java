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
 * Closes the connection pool gracefully when the web application is stopped or undeployed.
 */
@WebListener
public class MongoContextListener implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(MongoContextListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("MyPad web application starting. Initializing MongoDB connection...");
        try {
            MongoDatabase db = MongoConfig.getDatabase();
            MongoCollection<Document> padsCollection = db.getCollection(MongoConfig.getPadsCollectionName());

            // Create index on parentPath for efficient child pad listing
            padsCollection.createIndex(
                    Indexes.ascending("parentPath"),
                    new IndexOptions().name("idx_parentPath")
            );

            // Create index on updatedAt
            padsCollection.createIndex(
                    Indexes.descending("updatedAt"),
                    new IndexOptions().name("idx_updatedAt")
            );

            LOGGER.info("MongoDB initialized and indexes verified for collection: " + MongoConfig.getPadsCollectionName());
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
