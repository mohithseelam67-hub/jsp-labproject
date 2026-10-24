<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mypad.dao.PadDao" %>
<%@ page import="com.mypad.model.Pad" %>
<%@ page import="com.mypad.util.JsonUtil" %>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Content-Type");

    if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
        return;
    }

    String currentUsername = (String) session.getAttribute("username");
    if (currentUsername == null || currentUsername.trim().isEmpty()) {
        JsonUtil.sendError(response, HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized. Please log in.");
        return;
    }

    try {
        PadDao padDao = new PadDao();
        List<Pad> userPads = padDao.findUserPads(currentUsername);

        int totalWords = 0;
        for (Pad p : userPads) {
            totalWords += p.getWordCount();
        }

        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":true,");
        sb.append("\"username\":\"").append(JsonUtil.escape(currentUsername)).append("\",");
        sb.append("\"totalPads\":").append(userPads.size()).append(",");
        sb.append("\"totalWords\":").append(totalWords).append(",");
        sb.append("\"pads\":[");
        for (int i = 0; i < userPads.size(); i++) {
            if (i > 0) sb.append(",");
            Pad p = userPads.get(i);
            String snippet = p.getContent() != null ? p.getContent() : "";
            if (snippet.length() > 120) {
                snippet = snippet.substring(0, 120) + "...";
            }
            sb.append("{");
            sb.append("\"path\":\"").append(JsonUtil.escape(p.getPath())).append("\",");
            sb.append("\"snippet\":\"").append(JsonUtil.escape(snippet)).append("\",");
            sb.append("\"version\":").append(p.getVersion()).append(",");
            sb.append("\"wordCount\":").append(p.getWordCount()).append(",");
            sb.append("\"visibility\":\"").append(JsonUtil.escape(p.getVisibility())).append("\",");
            sb.append("\"theme\":\"").append(JsonUtil.escape(p.getTheme())).append("\",");
            sb.append("\"updatedAt\":\"").append(JsonUtil.formatIso(p.getUpdatedAt())).append("\",");
            sb.append("\"createdAt\":\"").append(JsonUtil.formatIso(p.getCreatedAt())).append("\"");
            sb.append("}");
        }
        sb.append("]");
        sb.append("}");

        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, sb.toString());
    } catch (Exception e) {
        application.log("Error loading user pads", e);
        JsonUtil.sendError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading user pads: " + e.getMessage());
    }
%>
