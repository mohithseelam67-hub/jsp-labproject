<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.bson.Document" %>
<%@ page import="com.mypad.dao.PadDao" %>
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
        JsonUtil.sendError(response, HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Method Not Allowed. Use POST for deleting pads.");
        return;
    }

    try {
        Document body = JsonUtil.readJsonBody(request);
        String path = body.getString("path");
        if (path == null || path.trim().isEmpty()) {
            JsonUtil.sendError(response, HttpServletResponse.SC_BAD_REQUEST, "Missing required field: 'path'");
            return;
        }

        String currentUsername = (String) session.getAttribute("username");

        PadDao dao = new PadDao();
        dao.deletePad(path, currentUsername);

        JsonUtil.sendJson(response, HttpServletResponse.SC_OK, "{\"success\":true,\"message\":\"Pad deleted successfully\",\"path\":\"" + JsonUtil.escape(path) + "\"}");
    } catch (SecurityException e) {
        JsonUtil.sendError(response, HttpServletResponse.SC_FORBIDDEN, e.getMessage());
    } catch (Exception e) {
        application.log("Error deleting pad", e);
        JsonUtil.sendError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error deleting pad: " + e.getMessage());
    }
%>
