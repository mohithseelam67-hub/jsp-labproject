<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.bson.Document" %>
<%@ page import="com.mypad.dao.UserDao" %>
<%@ page import="com.mypad.model.User" %>
<%@ page import="com.mypad.util.JsonUtil" %>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Content-Type");

    if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
        return;
    }

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        JsonUtil.sendError(response, HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Method Not Allowed. Use POST for login.");
        return;
    }

    try {
        Document body = JsonUtil.readJsonBody(request);
        String identifier = body.getString("identifier"); // email or username
        if (identifier == null) {
            identifier = body.getString("email");
        }
        String password = body.getString("password");

        if (identifier == null || identifier.trim().isEmpty() || password == null || password.isEmpty()) {
            JsonUtil.sendError(response, HttpServletResponse.SC_BAD_REQUEST, "Email/Username and password are required.");
            return;
        }

        UserDao userDao = new UserDao();
        User user = userDao.authenticate(identifier, password);

        if (user == null) {
            JsonUtil.sendError(response, HttpServletResponse.SC_UNAUTHORIZED, "Invalid email/username or password.");
            return;
        }

        // Set session
        session.setAttribute("user", user);
        session.setAttribute("username", user.getUsername());

        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":true,");
        sb.append("\"message\":\"Logged in successfully\",");
        sb.append("\"user\":").append(JsonUtil.userToJson(user));
        sb.append("}");

        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, sb.toString());
    } catch (Exception e) {
        application.log("Error during login", e);
        JsonUtil.sendError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error during login: " + e.getMessage());
    }
%>
