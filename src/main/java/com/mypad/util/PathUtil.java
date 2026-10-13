package com.mypad.util;

import java.util.regex.Pattern;

/**
 * Utility class for validating and normalizing MyPad paths.
 *
 * Normalization Rules:
 * 1. Must not be null, empty, or whitespace only.
 * 2. Maximum length is 255 characters.
 * 3. Cannot contain null bytes (\0), backslashes (\), control characters, or path traversal sequences ("..", "./").
 * 4. Leading slash is required and automatically prepended if omitted (e.g., "notes/demo" -> "/notes/demo").
 * 5. Consecutive slashes are collapsed into a single slash (e.g., "//notes///demo" -> "/notes/demo").
 * 6. Trailing slashes are stripped (e.g., "/notes/demo/" -> "/notes/demo").
 * 7. Root-only path "/" is rejected because every pad requires a unique name identifier.
 * 8. Segment casing is strictly preserved (e.g., "/College/ML" is distinct and preserved as-is).
 */
public final class PathUtil {

    public static final int MAX_PATH_LENGTH = 255;
    private static final Pattern MULTI_SLASH = Pattern.compile("/+");

    private PathUtil() {
        // Utility class
    }

    /**
     * Validates and normalizes a pad path according to MyPad rules.
     *
     * @param rawPath the raw path provided by the user/request
     * @return the normalized canonical path
     * @throws IllegalArgumentException if the path is invalid
     */
    public static String normalizePath(String rawPath) {
        if (rawPath == null) {
            throw new IllegalArgumentException("Pad path cannot be null");
        }

        String path = rawPath.trim();
        if (path.isEmpty()) {
            throw new IllegalArgumentException("Pad path cannot be empty");
        }

        if (path.length() > MAX_PATH_LENGTH) {
            throw new IllegalArgumentException("Pad path exceeds maximum length of " + MAX_PATH_LENGTH + " characters");
        }

        // Check for disallowed characters: null bytes, backslashes, control characters
        for (int i = 0; i < path.length(); i++) {
            char c = path.charAt(i);
            if (c == '\0' || c == '\\' || c < 32 || c == 127) {
                throw new IllegalArgumentException("Pad path contains invalid or control characters");
            }
        }

        // Prevent path traversal attempts
        if (path.contains("..") || path.contains("./") || path.contains(".\\")) {
            throw new IllegalArgumentException("Path traversal sequences like '..' are not allowed");
        }

        // Collapse duplicate slashes
        path = MULTI_SLASH.matcher(path).replaceAll("/");

        // Ensure leading slash
        if (!path.startsWith("/")) {
            path = "/" + path;
        }

        // Strip trailing slash (unless length is 1)
        if (path.length() > 1 && path.endsWith("/")) {
            path = path.substring(0, path.length() - 1);
        }

        // Reject root-only path "/"
        if ("/".equals(path)) {
            throw new IllegalArgumentException("Root path '/' is not a valid pad name. Please specify a pad name, e.g. '/my-notes'");
        }

        return path;
    }

    /**
     * Normalizes a folder/parent path query for listing children.
     * Allows root "/" as a valid parent to list top-level pads.
     */
    public static String normalizeParentPath(String rawParentPath) {
        if (rawParentPath == null || rawParentPath.trim().isEmpty()) {
            return "/";
        }

        String path = rawParentPath.trim();
        if (path.length() > MAX_PATH_LENGTH) {
            throw new IllegalArgumentException("Parent path exceeds maximum length of " + MAX_PATH_LENGTH);
        }

        for (int i = 0; i < path.length(); i++) {
            char c = path.charAt(i);
            if (c == '\0' || c == '\\' || c < 32 || c == 127) {
                throw new IllegalArgumentException("Parent path contains invalid or control characters");
            }
        }

        if (path.contains("..") || path.contains("./")) {
            throw new IllegalArgumentException("Path traversal sequences like '..' are not allowed");
        }

        path = MULTI_SLASH.matcher(path).replaceAll("/");
        if (!path.startsWith("/")) {
            path = "/" + path;
        }
        if (path.length() > 1 && path.endsWith("/")) {
            path = path.substring(0, path.length() - 1);
        }

        return path;
    }

    /**
     * Computes the immediate parent path for a normalized pad path.
     * Examples:
     * "/college/ml" -> "/college"
     * "/college" -> "/"
     * "/college/dept/cs" -> "/college/dept"
     *
     * @param normalizedPath a normalized path starting with "/"
     * @return the parent path
     */
    public static String getParentPath(String normalizedPath) {
        int lastSlashIndex = normalizedPath.lastIndexOf('/');
        if (lastSlashIndex <= 0) {
            return "/";
        }
        return normalizedPath.substring(0, lastSlashIndex);
    }
}
