<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="com.mypad.util.JsonUtil" %>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Content-Type");

    if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
        return;
    }

    String username = (String) session.getAttribute("username");
    if (username != null && !username.trim().isEmpty()) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"authenticated\":true,");
        sb.append("\"user\":{\"username\":\"").append(JsonUtil.escape(username)).append("\"}");
        sb.append("}");
        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, sb.toString());
    } else {
        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, "{\"authenticated\":false,\"user\":null}");
    }
%>
