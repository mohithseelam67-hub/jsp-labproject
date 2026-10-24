<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mypad.dao.UserDao" %>
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
        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, "{\"success\":true,\"suggestions\":[]}");
        return;
    }

    String prefix = query.trim();
    if (prefix.startsWith("@")) {
        prefix = prefix.substring(1);
    }

    try {
        UserDao userDao = new UserDao();
        List<String> suggestions = userDao.autocompleteUsernames(prefix, 8);

        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":true,");
        sb.append("\"query\":\"").append(JsonUtil.escape(query)).append("\",");
        sb.append("\"suggestions\":[");
        for (int i = 0; i < suggestions.size(); i++) {
            if (i > 0) sb.append(",");
            sb.append("\"").append(JsonUtil.escape(suggestions.get(i))).append("\"");
        }
        sb.append("]");
        sb.append("}");

        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, sb.toString());
    } catch (Exception e) {
        application.log("Error in user autocomplete", e);
        JsonUtil.sendError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Autocomplete error: " + e.getMessage());
    }
%>
