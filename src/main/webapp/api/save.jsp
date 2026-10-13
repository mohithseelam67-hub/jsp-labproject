<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="org.bson.Document" %>
<%@ page import="com.mypad.dao.PadDao" %>
<%@ page import="com.mypad.model.Pad" %>
<%@ page import="com.mypad.util.JsonUtil" %>
<%
    response.setHeader("Access-Control-Allow-Origin", "*");
    response.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
    response.setHeader("Access-Control-Allow-Headers", "Content-Type");
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
        return;
    }

    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        JsonUtil.sendError(response, HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Method Not Allowed. Use POST for saving pads.");
        return;
    }

    try {
        Document body = JsonUtil.readJsonBody(request);

        String path = body.getString("path");
        if (path == null || path.trim().isEmpty()) {
            JsonUtil.sendError(response, HttpServletResponse.SC_BAD_REQUEST, "Missing required JSON field: 'path'");
            return;
        }

        String content = body.getString("content");
        if (content == null) {
            content = "";
        }

        Integer version = null;
        Object versionObj = body.get("version");
        if (versionObj instanceof Number) {
            version = ((Number) versionObj).intValue();
        }

        PadDao dao = new PadDao();
        PadDao.SaveResult result = dao.save(path, content, version);

        if (result.isConflict()) {
            response.setStatus(HttpServletResponse.SC_CONFLICT); // 409
            StringBuilder sb = new StringBuilder();
            sb.append("{");
            sb.append("\"success\":false,");
            sb.append("\"conflict\":true,");
            sb.append("\"error\":\"Version conflict: pad has been modified by another session. Please reload the latest version.\",");
            sb.append("\"currentVersion\":").append(result.getCurrentVersionOnConflict()).append(",");
            sb.append("\"status\":409");
            sb.append("}");
            out.print(sb.toString());
            out.flush();
            return;
        }

        if (result.isSuccess()) {
            Pad updatedPad = result.getPad();
            response.setStatus(HttpServletResponse.SC_OK);
            StringBuilder sb = new StringBuilder();
            sb.append("{");
            sb.append("\"success\":true,");
            sb.append("\"path\":\"").append(JsonUtil.escape(updatedPad.getPath())).append("\",");
            sb.append("\"content\":\"").append(JsonUtil.escape(updatedPad.getContent())).append("\",");
            sb.append("\"createdAt\":\"").append(JsonUtil.formatIso(updatedPad.getCreatedAt())).append("\",");
            sb.append("\"updatedAt\":\"").append(JsonUtil.formatIso(updatedPad.getUpdatedAt())).append("\",");
            sb.append("\"version\":").append(updatedPad.getVersion()).append(",");
            sb.append("\"parentPath\":\"").append(JsonUtil.escape(updatedPad.getParentPath())).append("\"");
            sb.append("}");
            out.print(sb.toString());
            out.flush();
            return;
        }

        JsonUtil.sendError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database write could not be confirmed");
    } catch (IllegalArgumentException e) {
        JsonUtil.sendError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
    } catch (Exception e) {
        application.log("Error handling POST save pad", e);
        JsonUtil.sendError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database or server error saving pad");
    }
%>
