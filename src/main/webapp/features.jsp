<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Features — MyPad</title>
    <meta name="description" content="Discover everything MyPad has to offer: instant URL pads, nested hierarchy, real-time auto-saving, and complete privacy.">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mypad.css">
    <style>
        .feature-hero {
            max-width: 800px;
            margin: 0 auto;
            padding: 4rem 1.25rem 2.5rem;
            text-align: center;
        }
        .features-grid {
            max-width: 1060px;
            margin: 0 auto 4rem;
            padding: 0 1.25rem;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
        }
        .feature-card {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 14px;
            padding: 1.75rem;
            box-shadow: var(--shadow-sm);
            transition: all 0.15s ease;
        }
        .feature-card:hover {
            border-color: var(--text-secondary);
            transform: translateY(-2px);
        }
        .feature-icon-box {
            width: 2.5rem;
            height: 2.5rem;
            border-radius: 10px;
            background: var(--btn-secondary-bg);
            border: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            margin-bottom: 1.25rem;
            color: var(--text-primary);
        }
        .feature-title {
            font-size: 1.15rem;
            font-weight: 600;
            letter-spacing: -0.015em;
            margin-bottom: 0.5rem;
        }
        .feature-desc {
            font-size: 0.875rem;
            color: var(--text-secondary);
            line-height: 1.6;
        }
    </style>
</head>
<body>

    <%@ include file="includes/navbar.jsp" %>

    <main class="main-wrapper">
        <section class="feature-hero">
            <span style="font-family: var(--font-mono); font-size: 0.8rem; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.08em;">
                Everything you need
            </span>
            <h1 class="hero-title" style="font-size: 2.5rem; margin-top: 0.5rem;">Engineered for simplicity & speed</h1>
            <p class="hero-desc">
                MyPad eliminates the friction of notes applications. No complex hierarchies, no tedious invite links — just instant, flexible text sharing.
            </p>
        </section>

        <section class="features-grid">
            <div class="feature-card">
                <div class="feature-icon-box">&#127760;</div>
                <h3 class="feature-title">Instant URL Routing</h3>
                <p class="feature-desc">
                    Navigate to any path like <code>/standup/today</code> or <code>/project/spec</code> to instantly create or access that pad. The URL is your address.
                </p>
            </div>

            <div class="feature-card">
                <div class="feature-icon-box">&#9889;</div>
                <h3 class="feature-title">Real-Time Auto Saving</h3>
                <p class="feature-desc">
                    Every keystroke is debounced and synchronized with optimistic concurrency control. Never lose an idea or worry about pressing Save.
                </p>
            </div>

            <div class="feature-card">
                <div class="feature-icon-box">&#128193;</div>
                <h3 class="feature-title">Nested Sub-Pads</h3>
                <p class="feature-desc">
                    Organize effortlessly using filesystem-like slashes. View immediate children and browse nested directory trees with one click.
                </p>
            </div>

            <div class="feature-card">
                <div class="feature-icon-box">&#128274;</div>
                <h3 class="feature-title">Email & Password Auth</h3>
                <p class="feature-desc">
                    Claim your unique <code>@username</code>, manage personal pads, access your private dashboard, and protect confidential notes.
                </p>
            </div>

            <div class="feature-card">
                <div class="feature-icon-box">&#9728;</div>
                <h3 class="feature-title">Light & Dark Modes</h3>
                <p class="feature-desc">
                    Seamlessly switches between high-contrast crisp white and sleek Zinc dark mode with persistent user preferences.
                </p>
            </div>

            <div class="feature-card">
                <div class="feature-icon-box">&#128190;</div>
                <h3 class="feature-title">One-Click Export</h3>
                <p class="feature-desc">
                    Export your pads to standard Markdown (.md) or clean plain text (.txt) anytime for offline storage and archiving.
                </p>
            </div>
        </section>
    </main>

    <%@ include file="includes/footer.jsp" %>

</body>
</html>
