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
import com.mongodb.client.model.Sorts;
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
        return findOrCreate(rawPath, null);
    }

    /**
     * Retrieves an existing pad or creates a new empty one with optional owner.
     *
     * @param rawPath unnormalized pad path
     * @param ownerUsername optional username claiming ownership on initial creation
     * @return the existing or newly created Pad
     */
    public Pad findOrCreate(String rawPath, String ownerUsername) {
        String path = PathUtil.normalizePath(rawPath);
        MongoCollection<Document> collection = getCollection();

        Document doc = collection.find(Filters.eq("_id", path)).first();
        if (doc != null) {
            return Pad.fromDocument(doc);
        }

        // Pad does not exist, create it automatically
        Date now = new Date();
        String parentPath = PathUtil.getParentPath(path);
        boolean isProfilePad = (ownerUsername != null && !ownerUsername.trim().isEmpty()) || path.startsWith("/@");
        String visibility = isProfilePad ? "read-only" : "public";
        if (ownerUsername == null && path.startsWith("/@")) {
            int secondSlash = path.indexOf('/', 2);
            ownerUsername = secondSlash > 2 ? path.substring(2, secondSlash) : path.substring(2);
        }
        Pad newPad = new Pad(path, "", now, now, 1, parentPath, ownerUsername, visibility, "light");

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
     */
    public SaveResult save(String rawPath, String content, Integer expectedVersion) {
        return save(rawPath, content, expectedVersion, null);
    }

    /**
     * Saves pad content with optimistic concurrency control and optional owner assignment.
     */
    public SaveResult save(String rawPath, String content, Integer expectedVersion, String ownerUsername) {
        String path = PathUtil.normalizePath(rawPath);
        if (content == null) {
            content = "";
        }
        if (content.length() > MAX_CONTENT_LENGTH) {
            throw new IllegalArgumentException("Pad content exceeds maximum allowed limit of " + MAX_CONTENT_LENGTH + " characters");
        }

        // Enforce Read-Only permission if pad has an owner or belongs to a user namespace (/@username/...)
        String pathOwner = null;
        if (path.startsWith("/@")) {
            int secondSlash = path.indexOf('/', 2);
            pathOwner = secondSlash > 2 ? path.substring(2, secondSlash) : path.substring(2);
        }

        MongoCollection<Document> collection = getCollection();
        Document existing = collection.find(Filters.eq("_id", path)).first();
        if (existing != null) {
            String owner = existing.getString("ownerUsername");
            if (owner == null || owner.trim().isEmpty()) {
                owner = pathOwner;
            }
            String vis = existing.getString("visibility");
            if (owner != null && !owner.trim().isEmpty()) {
                if (vis == null || "public".equalsIgnoreCase(vis)) {
                    vis = "read-only";
                }
                if (ownerUsername == null || !owner.equalsIgnoreCase(ownerUsername.trim())) {
                    if ("read-only".equalsIgnoreCase(vis) || "private".equalsIgnoreCase(vis)) {
                        throw new SecurityException("This pad is read-only. Only @" + owner + " can edit it.");
                    }
                }
            }
        } else {
            // New pad creation: if path belongs to a user namespace (/@username/...)
            if (pathOwner != null && !pathOwner.trim().isEmpty()) {
                if (ownerUsername == null || !pathOwner.equalsIgnoreCase(ownerUsername.trim())) {
                    throw new SecurityException("This pad namespace belongs to @" + pathOwner + ". Only @" + pathOwner + " can create or edit it.");
                }
            }
        }

        if (ownerUsername == null || ownerUsername.trim().isEmpty()) {
            ownerUsername = pathOwner;
        }

        Date now = new Date();
        String parentPath = PathUtil.getParentPath(path);
        boolean isProfilePad = (ownerUsername != null && !ownerUsername.trim().isEmpty()) || path.startsWith("/@");
        String initialVisibility = isProfilePad ? "read-only" : "public";

        if (expectedVersion != null && expectedVersion > 0) {
            // Atomic update matching both path and current version
            Bson filter = Filters.and(
                    Filters.eq("_id", path),
                    Filters.eq("version", expectedVersion)
            );

            List<Bson> updatesList = new ArrayList<>();
            updatesList.add(Updates.set("content", content));
            updatesList.add(Updates.set("updatedAt", now));
            updatesList.add(Updates.set("parentPath", parentPath));
            updatesList.add(Updates.inc("version", 1));

            if (ownerUsername != null && !ownerUsername.trim().isEmpty()) {
                updatesList.add(Updates.setOnInsert("ownerUsername", ownerUsername.trim().toLowerCase()));
                updatesList.add(Updates.setOnInsert("visibility", initialVisibility));
            }

            Bson update = Updates.combine(updatesList);

            FindOneAndUpdateOptions options = new FindOneAndUpdateOptions().returnDocument(ReturnDocument.AFTER);
            Document updated = collection.findOneAndUpdate(filter, update, options);

            if (updated != null) {
                return SaveResult.success(Pad.fromDocument(updated));
            }

            // Either the pad does not exist yet, or version conflicted
            Document conflictedDoc = collection.find(Filters.eq("_id", path)).first();
            if (conflictedDoc != null) {
                // Stale version conflict
                Integer actualVersion = conflictedDoc.getInteger("version");
                LOGGER.info("Version conflict for pad " + path + ": expected=" + expectedVersion + ", actual=" + actualVersion);
                return SaveResult.conflict(actualVersion != null ? actualVersion : 1);
            }

            // Pad does not exist yet, create with version 1
            Pad newPad = new Pad(path, content, now, now, 1, parentPath, ownerUsername, initialVisibility, "light");
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
            List<Bson> updatesList = new ArrayList<>();
            updatesList.add(Updates.set("content", content));
            updatesList.add(Updates.set("updatedAt", now));
            updatesList.add(Updates.set("parentPath", parentPath));
            updatesList.add(Updates.setOnInsert("createdAt", now));
            updatesList.add(Updates.inc("version", 1));

            if (ownerUsername != null && !ownerUsername.trim().isEmpty()) {
                updatesList.add(Updates.setOnInsert("ownerUsername", ownerUsername.trim().toLowerCase()));
                updatesList.add(Updates.setOnInsert("visibility", initialVisibility));
            }

            Bson update = Updates.combine(updatesList);

            FindOneAndUpdateOptions options = new FindOneAndUpdateOptions()
                    .upsert(true)
                    .returnDocument(ReturnDocument.AFTER);

            Document updated = collection.findOneAndUpdate(filter, update, options);
            return SaveResult.success(Pad.fromDocument(updated));
        }
    }

    /**
     * Lists immediate child pads and directories directly under parentPath.
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
     * Searches public pads matching a query in the path or content.
     */
    public List<Pad> searchPublicPads(String query, int limit) {
        List<Pad> results = new ArrayList<>();
        if (query == null || query.trim().isEmpty()) {
            return results;
        }

        String q = query.trim();
        MongoCollection<Document> collection = getCollection();

        Bson publicFilter = Filters.ne("visibility", "private");
        Bson matchFilter = Filters.or(
                Filters.regex("_id", Pattern.compile(Pattern.quote(q), Pattern.CASE_INSENSITIVE)),
                Filters.regex("content", Pattern.compile(Pattern.quote(q), Pattern.CASE_INSENSITIVE))
        );

        Bson combined = Filters.and(publicFilter, matchFilter);

        for (Document doc : collection.find(combined).sort(Sorts.descending("updatedAt")).limit(limit > 0 ? limit : 20)) {
            results.add(Pad.fromDocument(doc));
        }

        return results;
    }

    /**
     * Finds all pads owned by a user (for the Dashboard).
     */
    public List<Pad> findUserPads(String ownerUsername) {
        List<Pad> list = new ArrayList<>();
        if (ownerUsername == null || ownerUsername.trim().isEmpty()) {
            return list;
        }

        MongoCollection<Document> collection = getCollection();
        Bson filter = Filters.eq("ownerUsername", ownerUsername.trim().toLowerCase());

        for (Document doc : collection.find(filter).sort(Sorts.descending("updatedAt"))) {
            list.add(Pad.fromDocument(doc));
        }

        return list;
    }

    /**
     * Deletes a pad if the user has permission (is owner or public pad).
     */
    public boolean deletePad(String rawPath, String currentUsername) {
        String path = PathUtil.normalizePath(rawPath);
        MongoCollection<Document> collection = getCollection();

        Document doc = collection.find(Filters.eq("_id", path)).first();
        if (doc == null) {
            return true;
        }

        String owner = doc.getString("ownerUsername");
        // If owned, only owner can delete
        if (owner != null && !owner.trim().isEmpty()) {
            if (currentUsername == null || !owner.equalsIgnoreCase(currentUsername.trim())) {
                throw new SecurityException("Unauthorized: You do not have permission to delete @" + owner + "'s pad.");
            }
        }

        collection.deleteOne(Filters.eq("_id", path));
        return true;
    }

    /**
     * Updates visibility and theme settings for a pad.
     */
    public Pad updateSettings(String rawPath, String visibility, String theme, String currentUsername) {
        String path = PathUtil.normalizePath(rawPath);
        MongoCollection<Document> collection = getCollection();

        Document doc = collection.find(Filters.eq("_id", path)).first();
        if (doc == null) {
            return null;
        }

        String owner = doc.getString("ownerUsername");
        if (owner != null && !owner.trim().isEmpty() && (currentUsername == null || !owner.equalsIgnoreCase(currentUsername.trim()))) {
            throw new SecurityException("Unauthorized: Only the owner can change pad settings.");
        }

        List<Bson> updates = new ArrayList<>();
        if (visibility != null && !visibility.trim().isEmpty()) {
            updates.add(Updates.set("visibility", visibility.trim().toLowerCase()));
        }
        if (theme != null && !theme.trim().isEmpty()) {
            updates.add(Updates.set("theme", theme.trim().toLowerCase()));
        }
        updates.add(Updates.set("updatedAt", new Date()));

        FindOneAndUpdateOptions options = new FindOneAndUpdateOptions().returnDocument(ReturnDocument.AFTER);
        Document updated = collection.findOneAndUpdate(Filters.eq("_id", path), Updates.combine(updates), options);
        return Pad.fromDocument(updated);
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
