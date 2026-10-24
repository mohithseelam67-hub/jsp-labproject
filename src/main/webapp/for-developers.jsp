<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MyPad for Developers — Simple API & Code Scratchpad</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mypad.css">
    <style>
        .dev-container {
            max-width: 860px;
            margin: 0 auto;
            padding: 4rem 1.25rem;
        }
        pre {
            background: var(--bg-surface);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 1rem 1.25rem;
            font-family: var(--font-mono);
            font-size: 0.85rem;
            color: var(--text-primary);
            overflow-x: auto;
            margin: 1rem 0 1.5rem;
        }
    </style>
</head>
<body>

    <%@ include file="includes/navbar.jsp" %>

    <main class="main-wrapper">
        <div class="dev-container">
            <h1 class="hero-title" style="text-align: left; font-size: 2.25rem;">Built for Developers</h1>
            <p class="hero-desc" style="text-align: left; max-width: 100%; margin-bottom: 2rem;">
                A clean scratchpad for code reviews, curl requests, JSON staging, and shell commands.
            </p>

            <h3 style="font-size: 1.15rem; font-weight: 600;">1. Fetch any pad via curl</h3>
            <pre>curl -X GET "http://localhost:8080/MyPadBackend/api/pad.jsp?path=/api/v1/spec"</pre>

            <h3 style="font-size: 1.15rem; font-weight: 600;">2. Save note content programmatically</h3>
            <pre>curl -X POST "http://localhost:8080/MyPadBackend/api/save.jsp" \
  -H "Content-Type: application/json" \
  -d '{"path":"/api/v1/spec","content":"{\"status\":\"healthy\"}","version":1}'</pre>

            <h3 style="font-size: 1.15rem; font-weight: 600;">3. List nested branches</h3>
            <pre>curl -X GET "http://localhost:8080/MyPadBackend/api/children.jsp?path=/api"</pre>

            <div style="margin-top: 2rem;">
                <a href="<%= request.getContextPath() %>/pad.jsp?path=/dev/scratch" class="btn btn-primary">
                    Open Developer Scratchpad &rarr;
                </a>
            </div>
        </div>
    </main>

    <%@ include file="includes/footer.jsp" %>

</body>
</html>
