package com.mypad.dao;

import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;

import org.bson.Document;
import org.bson.conversions.Bson;

import com.mongodb.MongoWriteException;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.FindOneAndUpdateOptions;
import com.mongodb.client.model.ReturnDocument;
import com.mongodb.client.model.Updates;
import com.mypad.config.MongoConfig;
import com.mypad.model.ChildPadInfo;
import com.mypad.model.Pad;
import com.mypad.util.PathUtil;

/**
 * Data Access Object for MyPad document operations in MongoDB.
 */
public class PadDao {

    private static final Logger LOGGER = Logger.getLogger(PadDao.class.getName());
    public static final int MAX_CONTENT_LENGTH = 2 * 1024 * 1024; // 2 MB limit per pad

    public static class SaveResult {
        private final boolean success;
        private final boolean conflict;
        private final Pad pad;
        private final Integer currentVersionOnConflict;

        private SaveResult(boolean success, boolean conflict, Pad pad, Integer currentVersionOnConflict) {
            this.success = success;
            this.conflict = conflict;
            this.pad = pad;
            this.currentVersionOnConflict = currentVersionOnConflict;
        }

        public static SaveResult success(Pad pad) {
            return new SaveResult(true, false, pad, null);
        }

        public static SaveResult conflict(Integer currentVersion) {
            return new SaveResult(false, true, null, currentVersion);
        }

        public boolean isSuccess() {
            return success;
        }

        public boolean isConflict() {
            return conflict;
        }

        public Pad getPad() {
            return pad;
        }

        public Integer getCurrentVersionOnConflict() {
            return currentVersionOnConflict;
        }
    }

    private MongoCollection<Document> getCollection() {
        MongoDatabase db = MongoConfig.getDatabase();
        return db.getCollection(MongoConfig.getPadsCollectionName());
    }

    /**
     * Retrieves an existing pad or creates a new empty one if not found.
     *
     * @param rawPath unnormalized pad path
     * @return the existing or newly created Pad
     */
    public Pad findOrCreate(String rawPath) {
        String path = PathUtil.normalizePath(rawPath);
        MongoCollection<Document> collection = getCollection();

        Document doc = collection.find(Filters.eq("_id", path)).first();
        if (doc != null) {
            return Pad.fromDocument(doc);
        }

        // Pad does not exist, create it automatically
        Date now = new Date();
        String parentPath = PathUtil.getParentPath(path);
        Pad newPad = new Pad(path, "", now, now, 1, parentPath);

        try {
            collection.insertOne(newPad.toDocument());
            return newPad;
        } catch (MongoWriteException e) {
            // Concurrent creation race condition (duplicate key)
            if (e.getError().getCode() == 11000) {
                Document existing = collection.find(Filters.eq("_id", path)).first();
                if (existing != null) {
                    return Pad.fromDocument(existing);
                }
            }
            LOGGER.log(Level.SEVERE, "Failed to create new pad for path: " + path, e);
            throw new RuntimeException("Database error creating pad: " + e.getMessage(), e);
        }
    }

    /**
     * Saves pad content with optimistic concurrency control using versions.
     *
     * @param rawPath unnormalized pad path
     * @param content pad text content
     * @param expectedVersion expected current version (or null for unconditional upsert)
     * @return SaveResult containing the updated pad or conflict details
     */
    public SaveResult save(String rawPath, String content, Integer expectedVersion) {
        String path = PathUtil.normalizePath(rawPath);
        if (content == null) {
            content = "";
        }
        if (content.length() > MAX_CONTENT_LENGTH) {
            throw new IllegalArgumentException("Pad content exceeds maximum allowed limit of " + MAX_CONTENT_LENGTH + " characters");
        }

        MongoCollection<Document> collection = getCollection();
        Date now = new Date();
        String parentPath = PathUtil.getParentPath(path);

        if (expectedVersion != null && expectedVersion > 0) {
            // Atomic update matching both path and current version
            Bson filter = Filters.and(
                    Filters.eq("_id", path),
                    Filters.eq("version", expectedVersion)
            );

            Bson update = Updates.combine(
                    Updates.set("content", content),
                    Updates.set("updatedAt", now),
                    Updates.set("parentPath", parentPath),
                    Updates.inc("version", 1)
            );

            FindOneAndUpdateOptions options = new FindOneAndUpdateOptions().returnDocument(ReturnDocument.AFTER);
            Document updated = collection.findOneAndUpdate(filter, update, options);

            if (updated != null) {
                return SaveResult.success(Pad.fromDocument(updated));
            }

            // Either the pad does not exist yet, or version conflicted
            Document existing = collection.find(Filters.eq("_id", path)).first();
            if (existing != null) {
                // Stale version conflict
                Integer actualVersion = existing.getInteger("version");
                LOGGER.info("Version conflict for pad " + path + ": expected=" + expectedVersion + ", actual=" + actualVersion);
                return SaveResult.conflict(actualVersion != null ? actualVersion : 1);
            }

            // Pad does not exist yet, create with version 1
            Pad newPad = new Pad(path, content, now, now, 1, parentPath);
            try {
                collection.insertOne(newPad.toDocument());
                return SaveResult.success(newPad);
            } catch (MongoWriteException e) {
                if (e.getError().getCode() == 11000) {
                    Document current = collection.find(Filters.eq("_id", path)).first();
                    return SaveResult.conflict(current != null ? current.getInteger("version") : 1);
                }
                throw e;
            }
        } else {
            // Unconditional upsert (if version is not enforced by client)
            Bson filter = Filters.eq("_id", path);
            Bson update = Updates.combine(
                    Updates.set("content", content),
                    Updates.set("updatedAt", now),
                    Updates.set("parentPath", parentPath),
                    Updates.setOnInsert("createdAt", now),
                    Updates.inc("version", 1)
            );

            FindOneAndUpdateOptions options = new FindOneAndUpdateOptions()
                    .upsert(true)
                    .returnDocument(ReturnDocument.AFTER);

            Document updated = collection.findOneAndUpdate(filter, update, options);
            return SaveResult.success(Pad.fromDocument(updated));
        }
    }

    /**
     * Lists immediate child pads and directories directly under parentPath.
     *
     * @param rawParentPath e.g. "/college" or "/"
     * @return list of immediate ChildPadInfo
     */
    public List<ChildPadInfo> findImmediateChildren(String rawParentPath) {
        String parentPath = PathUtil.normalizeParentPath(rawParentPath);
        MongoCollection<Document> collection = getCollection();

        String prefix = parentPath.equals("/") ? "/" : parentPath + "/";
        Bson filter = Filters.regex("_id", "^" + Pattern.quote(prefix));

        Map<String, ChildPadInfo> results = new LinkedHashMap<>();

        for (Document doc : collection.find(filter)) {
            String fullId = doc.getString("_id");
            if (fullId == null || !fullId.startsWith(prefix)) {
                continue;
            }

            String remainder = fullId.substring(prefix.length());
            int slashIndex = remainder.indexOf('/');

            if (slashIndex >= 0) {
                // Immediate child is an intermediate directory/branch
                String segment = remainder.substring(0, slashIndex);
                String childPath = prefix + segment;
                if (!results.containsKey(childPath)) {
                    results.put(childPath, new ChildPadInfo(segment, childPath, false, null, null));
                }
            } else {
                // Direct pad child
                String segment = remainder;
                String childPath = prefix + segment;
                results.put(childPath, new ChildPadInfo(
                        segment,
                        childPath,
                        true,
                        doc.getDate("updatedAt"),
                        doc.getInteger("version")
                ));
            }
        }

        return new ArrayList<>(results.values());
    }

    /**
     * Pings the MongoDB database server to verify connectivity.
     */
    public boolean ping() {
        try {
            MongoDatabase db = MongoConfig.getDatabase();
            Document pingDoc = db.runCommand(new Document("ping", 1));
            return pingDoc != null && (Number) pingDoc.get("ok") != null && ((Number) pingDoc.get("ok")).intValue() == 1;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "MongoDB ping failed", e);
            return false;
        }
    }
}
