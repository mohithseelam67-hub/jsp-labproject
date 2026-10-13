package com.mypad.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.bson.Document;

import com.mypad.model.ChildPadInfo;
import com.mypad.model.Pad;

/**
 * Clean, lightweight JSON utility that formats dates to standard ISO-8601,
 * escapes strings safely against injection, parses requests using BSON Document,
 * and standardizes API responses.
 */
public final class JsonUtil {

    public static final int MAX_REQUEST_SIZE_BYTES = 5 * 1024 * 1024; // 5 MB

    private JsonUtil() {
        // Utility class
    }

    /**
     * Formats a Date to an ISO-8601 UTC string (e.g. 2026-10-12T15:04:05Z).
     */
    public static String formatIso(Date date) {
        if (date == null) {
            return null;
        }
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
        sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
        return sdf.format(date);
    }

    /**
     * Safely escapes a string for JSON output.
     */
    public static String escape(String s) {
        if (s == null) {
            return "";
        }
        StringBuilder sb = new StringBuilder(s.length() + 16);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"':
                    sb.append("\\\"");
                    break;
                case '\\':
                    sb.append("\\\\");
                    break;
                case '\b':
                    sb.append("\\b");
                    break;
                case '\f':
                    sb.append("\\f");
                    break;
                case '\n':
                    sb.append("\\n");
                    break;
                case '\r':
                    sb.append("\\r");
                    break;
                case '\t':
                    sb.append("\\t");
                    break;
                default:
                    if (c < 32 || c >= 127 && c <= 159) {
                        String hex = Integer.toHexString(c);
                        sb.append("\\u");
                        for (int k = 0; k < 4 - hex.length(); k++) {
                            sb.append('0');
                        }
                        sb.append(hex);
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }

    /**
     * Serializes a Pad object to standard JSON.
     */
    public static String padToJson(Pad pad) {
        if (pad == null) {
            return "null";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"path\":\"").append(escape(pad.getPath())).append("\",");
        sb.append("\"content\":\"").append(escape(pad.getContent())).append("\",");
        sb.append("\"createdAt\":\"").append(formatIso(pad.getCreatedAt())).append("\",");
        sb.append("\"updatedAt\":\"").append(formatIso(pad.getUpdatedAt())).append("\",");
        sb.append("\"version\":").append(pad.getVersion()).append(",");
        sb.append("\"parentPath\":\"").append(escape(pad.getParentPath())).append("\"");
        sb.append("}");
        return sb.toString();
    }

    /**
     * Serializes a list of ChildPadInfo objects to JSON.
     */
    public static String childrenToJson(String parentPath, List<ChildPadInfo> children) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"parentPath\":\"").append(escape(parentPath)).append("\",");
        sb.append("\"count\":").append(children != null ? children.size() : 0).append(",");
        sb.append("\"children\":[");
        if (children != null) {
            for (int i = 0; i < children.size(); i++) {
                if (i > 0) sb.append(",");
                ChildPadInfo child = children.get(i);
                sb.append("{");
                sb.append("\"name\":\"").append(escape(child.getName())).append("\",");
                sb.append("\"path\":\"").append(escape(child.getPath())).append("\",");
                sb.append("\"isPad\":").append(child.isPad());
                if (child.getUpdatedAt() != null) {
                    sb.append(",\"updatedAt\":\"").append(formatIso(child.getUpdatedAt())).append("\"");
                }
                if (child.getVersion() != null) {
                    sb.append(",\"version\":").append(child.getVersion());
                }
                sb.append("}");
            }
        }
        sb.append("]");
        sb.append("}");
        return sb.toString();
    }

    /**
     * Reads and parses a JSON request body from HttpServletRequest.
     * Enforces maximum payload size limit.
     */
    public static Document readJsonBody(HttpServletRequest request) throws IOException {
        int contentLength = request.getContentLength();
        if (contentLength > MAX_REQUEST_SIZE_BYTES) {
            throw new IllegalArgumentException("Payload exceeds maximum allowed size of 5 MB");
        }

        StringBuilder buffer = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            char[] charBuffer = new char[4096];
            int bytesRead;
            int totalRead = 0;
            while ((bytesRead = reader.read(charBuffer)) != -1) {
                totalRead += bytesRead;
                if (totalRead > MAX_REQUEST_SIZE_BYTES) {
                    throw new IllegalArgumentException("Payload exceeds maximum allowed size of 5 MB");
                }
                buffer.append(charBuffer, 0, bytesRead);
            }
        }

        String jsonString = buffer.toString().trim();
        if (jsonString.isEmpty()) {
            throw new IllegalArgumentException("Empty JSON request body");
        }

        try {
            return Document.parse(jsonString);
        } catch (Exception e) {
            throw new IllegalArgumentException("Malformed JSON payload: " + e.getMessage(), e);
        }
    }

    /**
     * Sends an error response in JSON format.
     */
    public static void sendError(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.write("{\"success\":false,\"error\":\"" + escape(message) + "\",\"status\":" + statusCode + "}");
        out.flush();
    }

    /**
     * Sends a successful JSON response string.
     */
    public static void sendJson(HttpServletResponse response, int statusCode, String json) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        out.write(json);
        out.flush();
    }
}
