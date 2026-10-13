<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.List" %>
<%@ page import="com.mypad.dao.PadDao" %>
<%@ page import="com.mypad.model.ChildPadInfo" %>
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
        JsonUtil.sendError(response, HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Method Not Allowed. Use GET for listing child pads.");
        return;
    }

    String pathParam = request.getParameter("path");
    if (pathParam == null || pathParam.trim().isEmpty()) {
        pathParam = "/";
    }

    try {
        String normalizedParent = PathUtil.normalizeParentPath(pathParam);
        PadDao dao = new PadDao();
        List<ChildPadInfo> children = dao.findImmediateChildren(normalizedParent);

        response.setStatus(HttpServletResponse.SC_OK);
        String json = JsonUtil.childrenToJson(normalizedParent, children);
        out.print(json);
        out.flush();
    } catch (IllegalArgumentException e) {
        JsonUtil.sendError(response, HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
    } catch (Exception e) {
        application.log("Error listing children for path: " + pathParam, e);
        JsonUtil.sendError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database or server error listing child pads");
    }
%>
