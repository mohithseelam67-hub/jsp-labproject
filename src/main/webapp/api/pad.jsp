<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="com.mypad.dao.PadDao" %>
<%@ page import="com.mypad.model.Pad" %>
<%@ page import="com.mypad.util.JsonUtil" %>
<%@ page import="com.mypad.util.PathUtil" %>
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
        JsonUtil.sendError(response, HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Method Not Allowed. Use GET for retrieving pads.");
        return;
    }

    String pathParam = request.getParameter("path");
    if (pathParam == null || pathParam.trim().isEmpty()) {
        JsonUtil.sendError(response, HttpServletResponse.SC_BAD_REQUEST, "Missing required query parameter: 'path' (e.g. ?path=/college/ml)");
        return;
    }

    try {
        PadDao dao = new PadDao();
        Pad pad = dao.findOrCreate(pathParam);

        response.setStatus(HttpServletResponse.SC_OK);
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":true,");
        sb.append("\"path\":\"").append(JsonUtil.escape(pad.getPath())).append("\",");
        sb.append("\"content\":\"").append(JsonUtil.escape(pad.getContent())).append("\",");
        sb.append("\"createdAt\":\"").append(JsonUtil.formatIso(pad.getCreatedAt())).append("\",");
        sb.append("\"updatedAt\":\"").append(JsonUtil.formatIso(pad.getUpdatedAt())).append("\",");
        sb.append("\"version\":").append(pad.getVersion()).append(",");
        sb.append("\"parentPath\":\"").append(JsonUtil.escape(pad.getParentPath())).append("\"");
        sb.append("}");

        out.print(sb.toString());
        out.flush();
    } catch (IllegalArgumentException e) {
        JsonUtil.sendError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
    } catch (Exception e) {
        application.log("Error handling GET pad for path: " + pathParam, e);
        JsonUtil.sendError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database or server error processing request");
    }
%>
