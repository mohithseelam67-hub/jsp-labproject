package com.mypad.dao;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;

import org.bson.Document;
import org.bson.conversions.Bson;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import com.mypad.config.MongoConfig;
import com.mypad.model.User;

/**
 * Data Access Object for User authentication and profile management.
 */
public class UserDao {

    private static final Logger LOGGER = Logger.getLogger(UserDao.class.getName());
    public static final String USERS_COLLECTION = "users";

    public static final Set<String> RESERVED_USERNAMES = new HashSet<>(Arrays.asList(
            "api", "auth", "login", "signin", "signout", "signup", "logout",
            "dashboard", "settings", "search", "admin", "features", "how-it-works",
            "use-cases", "for-students", "for-developers", "online-notepad", "_next",
            "favicon.ico", "robots.txt", "sitemap.xml", "pad", "pads", "file", "files",
            "user", "users", "help", "about", "terms", "privacy", "contact"
    ));

    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[a-z0-9][a-z0-9_-]{1,28}[a-z0-9]$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$");

    private MongoCollection<Document> getCollection() {
        MongoDatabase db = MongoConfig.getDatabase();
        return db.getCollection(USERS_COLLECTION);
    }

    /**
     * Validates a username according to MyPad standards.
     * 3 to 30 chars, lowercase alphanumeric, underscore, hyphen.
     */
    public static String validateUsername(String rawUsername) {
        if (rawUsername == null || rawUsername.trim().isEmpty()) {
            return "Username is required.";
        }
        String normalized = rawUsername.trim().toLowerCase();
        if (normalized.length() < 3) {
            return "Username must be at least 3 characters long.";
        }
        if (normalized.length() > 30) {
            return "Username cannot exceed 30 characters.";
        }
        if (!USERNAME_PATTERN.matcher(normalized).matches()) {
            return "Username can only contain lowercase letters, numbers, hyphens, and underscores, and must start and end with an alphanumeric character.";
        }
        if (RESERVED_USERNAMES.contains(normalized)) {
            return "\"" + normalized + "\" is a reserved system name and cannot be used.";
        }
        return null;
    }

    /**
     * Validates an email address.
     */
    public static String validateEmail(String rawEmail) {
        if (rawEmail == null || rawEmail.trim().isEmpty()) {
            return "Email is required.";
        }
        String normalized = rawEmail.trim().toLowerCase();
        if (!EMAIL_PATTERN.matcher(normalized).matches()) {
            return "Please provide a valid email address.";
        }
        return null;
    }

    /**
     * Registers a new user with email and password.
     */
    public User register(String email, String username, String password) throws IllegalArgumentException {
        String emailError = validateEmail(email);
        if (emailError != null) {
            throw new IllegalArgumentException(emailError);
        }

        String usernameError = validateUsername(username);
        if (usernameError != null) {
            throw new IllegalArgumentException(usernameError);
        }

        if (password == null || password.length() < 6) {
            throw new IllegalArgumentException("Password must be at least 6 characters long.");
        }

        String normEmail = email.trim().toLowerCase();
        String normUsername = username.trim().toLowerCase();

        MongoCollection<Document> collection = getCollection();

        // Check if username or email is already taken
        Document existingUsername = collection.find(Filters.eq("username", normUsername)).first();
        if (existingUsername != null) {
            throw new IllegalArgumentException("Username @" + normUsername + " is already taken.");
        }

        Document existingEmail = collection.find(Filters.eq("email", normEmail)).first();
        if (existingEmail != null) {
            throw new IllegalArgumentException("An account with this email already exists.");
        }

        // Generate salt & hash
        String salt = generateSalt();
        String passwordHash = hashPassword(password, salt);

        Date now = new Date();
        User newUser = new User(normEmail, normUsername, passwordHash, salt, now, now);

        try {
            collection.insertOne(newUser.toDocument());
            LOGGER.info("Registered new user: " + normUsername + " (" + normEmail + ")");
            return newUser;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to register user " + normUsername, e);
            throw new RuntimeException("Error registering user: " + e.getMessage(), e);
        }
    }

    /**
     * Authenticates a user by email/username and password.
     */
    public User authenticate(String emailOrUsername, String password) {
        if (emailOrUsername == null || emailOrUsername.trim().isEmpty() || password == null) {
            return null;
        }

        String identifier = emailOrUsername.trim().toLowerCase();
        MongoCollection<Document> collection = getCollection();

        Bson filter = Filters.or(
                Filters.eq("email", identifier),
                Filters.eq("username", identifier)
        );

        Document doc = collection.find(filter).first();
        if (doc == null) {
            return null;
        }

        User user = User.fromDocument(doc);
        String expectedHash = hashPassword(password, user.getSalt());

        if (expectedHash != null && expectedHash.equals(user.getPasswordHash())) {
            return user;
        }

        return null;
    }

    /**
     * Finds a user by username.
     */
    public User findByUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return null;
        }
        Document doc = getCollection().find(Filters.eq("username", username.trim().toLowerCase())).first();
        return User.fromDocument(doc);
    }

    /**
     * Finds a user by email.
     */
    public User findByEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return null;
        }
        Document doc = getCollection().find(Filters.eq("email", email.trim().toLowerCase())).first();
        return User.fromDocument(doc);
    }

    /**
     * Searches usernames for autocomplete (when typing @prefix).
     */
    public List<String> autocompleteUsernames(String prefix, int limit) {
        List<String> list = new ArrayList<>();
        if (prefix == null || prefix.trim().isEmpty()) {
            return list;
        }
        String cleanPrefix = prefix.trim().toLowerCase();
        Bson filter = Filters.regex("username", "^" + Pattern.quote(cleanPrefix));
        for (Document doc : getCollection().find(filter).limit(limit > 0 ? limit : 8)) {
            String u = doc.getString("username");
            if (u != null) {
                list.add(u);
            }
        }
        return list;
    }

    /**
     * Generates a 16-byte random salt encoded as Base64.
     */
    private static String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    /**
     * Computes SHA-256(password + salt) encoded as Base64.
     */
    public static String hashPassword(String password, String salt) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            digest.update(salt.getBytes(StandardCharsets.UTF_8));
            byte[] hash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not supported", e);
        }
    }
}
