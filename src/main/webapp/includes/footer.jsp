<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String footerContext = request.getContextPath();
%>
<footer class="footer">
    <div class="footer-container">
        <div class="footer-brand">
            <div class="logo-box" style="width: 1.25rem; height: 1.25rem; font-size: 0.65rem;">M</div>
            <span style="font-weight: 600; font-size: 0.85rem; color: var(--text-primary);">MyPad</span>
            <span style="font-family: var(--font-mono); color: var(--text-muted); font-size: 0.75rem;">&copy; 2026</span>
            <span style="font-family: var(--font-mono); font-size: 0.75rem; color: var(--text-secondary); margin-left: 0.5rem; display: inline-flex; align-items: center;">
                <span class="operational-dot"></span>Operational
            </span>
        </div>
        <nav class="footer-links" aria-label="Footer Navigation">
            <a href="<%= footerContext %>/online-notepad.jsp">Online Notepad</a>
            <a href="<%= footerContext %>/features.jsp">Features</a>
            <a href="<%= footerContext %>/how-it-works.jsp">How It Works</a>
            <a href="<%= footerContext %>/use-cases.jsp">Use Cases</a>
            <a href="<%= footerContext %>/for-developers.jsp">For Developers</a>
            <a href="<%= footerContext %>/for-students.jsp">For Students</a>
        </nav>
    </div>
</footer>
