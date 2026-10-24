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

    String query = request.getParameter("q");
    if (query == null || query.trim().isEmpty()) {
        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, "{\"success\":true,\"query\":\"\",\"pads\":[]}");
        return;
    }

    try {
        PadDao padDao = new PadDao();
        List<Pad> pads = padDao.searchPublicPads(query.trim(), 20);

        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":true,");
        sb.append("\"query\":\"").append(JsonUtil.escape(query)).append("\",");
        sb.append("\"count\":").append(pads.size()).append(",");
        sb.append("\"pads\":[");
        for (int i = 0; i < pads.size(); i++) {
            if (i > 0) sb.append(",");
            Pad p = pads.get(i);
            // Create snippet
            String snippet = p.getContent() != null ? p.getContent() : "";
            if (snippet.length() > 140) {
                snippet = snippet.substring(0, 140) + "...";
            }
            sb.append("{");
            sb.append("\"path\":\"").append(JsonUtil.escape(p.getPath())).append("\",");
            sb.append("\"snippet\":\"").append(JsonUtil.escape(snippet)).append("\",");
            sb.append("\"updatedAt\":\"").append(JsonUtil.formatIso(p.getUpdatedAt())).append("\",");
            sb.append("\"version\":").append(p.getVersion()).append(",");
            sb.append("\"wordCount\":").append(p.getWordCount()).append(",");
            sb.append("\"ownerUsername\":").append(p.getOwnerUsername() != null ? "\"" + JsonUtil.escape(p.getOwnerUsername()) + "\"" : "null");
            sb.append("}");
        }
        sb.append("]");
        sb.append("}");

        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, sb.toString());
    } catch (Exception e) {
        application.log("Error searching pads", e);
        JsonUtil.sendError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error searching pads: " + e.getMessage());
    }
%>
