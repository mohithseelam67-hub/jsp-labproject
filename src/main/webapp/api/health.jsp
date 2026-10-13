<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.mypad.config.MongoConfig" %>
<%@ page import="com.mypad.dao.PadDao" %>
<%@ page import="com.mypad.util.JsonUtil" %>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Content-Type");
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
        return;
    }

    if (!"GET".equalsIgnoreCase(request.getMethod())) {
        JsonUtil.sendError(response, HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Method Not Allowed. Use GET for health check.");
        return;
    }

    Date now = new Date();
    String nowIso = JsonUtil.formatIso(now);
    String dbName = MongoConfig.getDatabaseName();

    try {
        PadDao dao = new PadDao();
        boolean isConnected = dao.ping();

        if (isConnected) {
            response.setStatus(HttpServletResponse.SC_OK);
            out.print("{\"status\":\"UP\",\"database\":\"CONNECTED\",\"databaseName\":\"" + JsonUtil.escape(dbName) + "\",\"timestamp\":\"" + nowIso + "\"}");
        } else {
            response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE); // 503
            out.print("{\"status\":\"DOWN\",\"database\":\"DISCONNECTED\",\"databaseName\":\"" + JsonUtil.escape(dbName) + "\",\"timestamp\":\"" + nowIso + "\"}");
        }
    } catch (Exception e) {
        application.log("Error in health check endpoint", e);
        response.setStatus(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
        out.print("{\"status\":\"DOWN\",\"database\":\"DISCONNECTED\",\"databaseName\":\"" + JsonUtil.escape(dbName) + "\",\"timestamp\":\"" + nowIso + "\"}");
    }
    out.flush();
%>
