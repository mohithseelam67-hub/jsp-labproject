<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Use Cases — MyPad</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mypad.css">
    <style>
        .use-case-container {
            max-width: 960px;
            margin: 0 auto;
            padding: 4rem 1.25rem;
        }
        .grid-2 {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-top: 2.5rem;
        }
        .use-case-card {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 14px;
            padding: 1.75rem;
            box-shadow: var(--shadow-sm);
        }
        .use-case-badge {
            font-family: var(--font-mono);
            font-size: 0.75rem;
            color: var(--text-muted);
            margin-bottom: 0.5rem;
            display: block;
        }
        .use-case-title {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }
        .use-case-text {
            font-size: 0.875rem;
            color: var(--text-secondary);
            line-height: 1.6;
        }
    </style>
</head>
<body>

    <%@ include file="includes/navbar.jsp" %>

    <main class="main-wrapper">
        <div class="use-case-container">
            <div style="text-align: center;">
                <span style="font-family: var(--font-mono); font-size: 0.8rem; font-weight: 600; color: var(--text-muted); text-transform: uppercase;">Versatile & Fast</span>
                <h1 class="hero-title" style="font-size: 2.5rem; margin-top: 0.5rem;">Built for Every Workflow</h1>
                <p class="hero-desc" style="margin: 0.75rem auto 0;">From quick developer snippets to university lecture study groups.</p>
            </div>

            <div class="grid-2">
                <div class="use-case-card">
                    <span class="use-case-badge">01 &bull; Engineering</span>
                    <h3 class="use-case-title">Code Snippets & Architecture</h3>
                    <p class="use-case-text">
                        Paste stack traces, SQL queries, or API schemas on a shared pad like <code>/api/v2/spec</code> during debugging sessions.
                    </p>
                </div>

                <div class="use-case-card">
                    <span class="use-case-badge">02 &bull; Academia</span>
                    <h3 class="use-case-title">Collaborative Lecture Notes</h3>
                    <p class="use-case-text">
                        Create hierarchical pads like <code>/college/cs101/week3</code> so study groups can take notes in parallel.
                    </p>
                </div>

                <div class="use-case-card">
                    <span class="use-case-badge">03 &bull; Teams</span>
                    <h3 class="use-case-title">Daily Standups & Agendas</h3>
                    <p class="use-case-text">
                        Keep meeting notes organized by date: <code>/team/standup/2026-10-24</code>. No email invites or heavy apps required.
                    </p>
                </div>

                <div class="use-case-card">
                    <span class="use-case-badge">04 &bull; Cross-Device</span>
                    <h3 class="use-case-title">Instant Clipboard Transfer</h3>
                    <p class="use-case-text">
                        Quickly send URLs, commands, or text between your phone, Mac, and Linux workstations by typing a temporary pad name.
                    </p>
                </div>
            </div>
        </div>
    </main>

    <%@ include file="includes/footer.jsp" %>

</body>
</html>
