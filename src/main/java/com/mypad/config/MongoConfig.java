package com.mypad.config;

import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.mongodb.ConnectionString;
import com.mongodb.MongoClientSettings;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoDatabase;

/**
 * Centralized MongoDB configuration and client lifecycle manager.
 * Reuses a single shared MongoClient instance across the web application.
 */
public final class MongoConfig {

    private static final Logger LOGGER = Logger.getLogger(MongoConfig.class.getName());

    private static final String DEFAULT_URI = "mongodb://127.0.0.1:27017";
    private static final String DEFAULT_DATABASE_NAME = "mypad_jsp";
    private static final String PADS_COLLECTION_NAME = "pads";

    private static volatile MongoClient mongoClient;
    private static volatile MongoDatabase mongoDatabase;
    private static final Object LOCK = new Object();

    private MongoConfig() {
        // Utility / singleton class
    }

    public static String getConnectionString() {
        String envUri = System.getenv("MONGODB_URI");
        if (envUri != null && !envUri.trim().isEmpty()) {
            return envUri.trim();
        }
        String sysProp = System.getProperty("mongodb.uri");
        if (sysProp != null && !sysProp.trim().isEmpty()) {
            return sysProp.trim();
        }
        return DEFAULT_URI;
    }

    public static String getDatabaseName() {
        String envDb = System.getenv("MONGODB_DATABASE");
        if (envDb != null && !envDb.trim().isEmpty()) {
            return envDb.trim();
        }
        String sysProp = System.getProperty("mongodb.database");
        if (sysProp != null && !sysProp.trim().isEmpty()) {
            return sysProp.trim();
        }
        return DEFAULT_DATABASE_NAME;
    }

    public static String getPadsCollectionName() {
        return PADS_COLLECTION_NAME;
    }

    /**
     * Initializes the MongoClient if not already initialized.
     */
    public static void init() {
        getClient();
    }

    /**
     * Retrieves the shared MongoClient instance with thread-safe double-checked locking.
     */
    public static MongoClient getClient() {
        if (mongoClient == null) {
            synchronized (LOCK) {
                if (mongoClient == null) {
                    try {
                        String uri = getConnectionString();
                        ConnectionString connString = new ConnectionString(uri);
                        MongoClientSettings settings = MongoClientSettings.builder()
                                .applyConnectionString(connString)
                                .applyToSocketSettings(builder ->
                                        builder.connectTimeout(5, TimeUnit.SECONDS)
                                               .readTimeout(10, TimeUnit.SECONDS))
                                .applyToConnectionPoolSettings(builder ->
                                        builder.maxSize(50)
                                               .minSize(5)
                                               .maxWaitTime(5, TimeUnit.SECONDS))
                                .build();

                        mongoClient = MongoClients.create(settings);
                        mongoDatabase = mongoClient.getDatabase(getDatabaseName());
                        LOGGER.info("Shared MongoClient successfully initialized for database: " + getDatabaseName());
                    } catch (Exception e) {
                        LOGGER.log(Level.SEVERE, "Failed to initialize MongoDB client", e);
                        throw new RuntimeException("Could not connect to MongoDB: " + e.getMessage(), e);
                    }
                }
            }
        }
        return mongoClient;
    }

    /**
     * Retrieves the shared MongoDatabase instance.
     */
    public static MongoDatabase getDatabase() {
        if (mongoDatabase == null) {
            getClient();
        }
        return mongoDatabase;
    }

    /**
     * Closes the shared MongoClient upon application shutdown.
     */
    public static void close() {
        synchronized (LOCK) {
            if (mongoClient != null) {
                try {
                    LOGGER.info("Closing shared MongoClient connection pool...");
                    mongoClient.close();
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Error closing MongoClient", e);
                } finally {
                    mongoClient = null;
                    mongoDatabase = null;
                }
            }
        }
    }
}
