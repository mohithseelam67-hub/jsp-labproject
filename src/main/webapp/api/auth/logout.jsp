<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="com.mypad.util.JsonUtil" %>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Content-Type");

    if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
        return;
    }

    session.removeAttribute("user");
    session.removeAttribute("username");
    session.invalidate();

    JsonUtil.sendJson(response, HttpServletResponse.SC_OK, "{\"success\":true,\"message\":\"Logged out successfully\"}");
%>
