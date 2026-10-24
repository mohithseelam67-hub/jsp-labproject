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
        JsonUtil.sendError(response, HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Method Not Allowed. Use POST for registration.");
        return;
    }

    try {
        Document body = JsonUtil.readJsonBody(request);
        String email = body.getString("email");
        String username = body.getString("username");
        String password = body.getString("password");

        UserDao userDao = new UserDao();
        User user = userDao.register(email, username, password);

        // Store user in HTTP session
        session.setAttribute("user", user);
        session.setAttribute("username", user.getUsername());

        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":true,");
        sb.append("\"message\":\"Account created successfully\",");
        sb.append("\"user\":").append(JsonUtil.userToJson(user));
        sb.append("}");

        JsonUtil.sendJson(response, HttpServletResponse.SC_CREATED, sb.toString());
    } catch (IllegalArgumentException e) {
        JsonUtil.sendError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
    } catch (Exception e) {
        application.log("Error in registration", e);
        JsonUtil.sendError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error during registration: " + e.getMessage());
    }
%>
