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
        String currentUsername = (String) session.getAttribute("username");

        PadDao dao = new PadDao();
        Pad pad = dao.findOrCreate(pathParam, currentUsername);

        // Privacy check
        if ("private".equalsIgnoreCase(pad.getVisibility())) {
            if (pad.getOwnerUsername() != null && !pad.getOwnerUsername().equalsIgnoreCase(currentUsername)) {
                JsonUtil.sendError(response, HttpServletResponse.SC_FORBIDDEN, "This pad is private to @" + pad.getOwnerUsername());
                return;
            }
        }

        response.setStatus(HttpServletResponse.SC_OK);
        out.print(JsonUtil.padToJson(pad, currentUsername));
        out.flush();
    } catch (IllegalArgumentException e) {
        JsonUtil.sendError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
    } catch (Exception e) {
        application.log("Error handling GET pad for path: " + pathParam, e);
        JsonUtil.sendError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database or server error processing request");
    }
%>
