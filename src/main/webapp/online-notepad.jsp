<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Free Online Notepad — MyPad</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/mypad.css">
    <style>
        .notepad-hero {
            max-width: 800px;
            margin: 0 auto;
            padding: 4rem 1.25rem;
            text-align: center;
        }
        .benefit-box {
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 14px;
            padding: 2rem;
            margin-top: 2rem;
            text-align: left;
            box-shadow: var(--shadow-sm);
        }
        .benefit-box h3 {
            font-size: 1.25rem;
            margin-bottom: 0.75rem;
        }
        .benefit-box p {
            color: var(--text-secondary);
            line-height: 1.7;
            font-size: 0.925rem;
        }
    </style>
</head>
<body>

    <%@ include file="includes/navbar.jsp" %>

    <main class="main-wrapper">
        <section class="notepad-hero">
            <h1 class="hero-title">The Fastest Free Online Notepad</h1>
            <p class="hero-desc">
                No sign-up popups, no ads, and zero latency. Just pure writing space.
            </p>
            <div style="margin-top: 2rem;">
                <a href="<%= request.getContextPath() %>/pad.jsp?path=/quick-notes" class="btn btn-primary" style="padding: 0.75rem 1.5rem; font-size: 1rem;">
                    Launch Quick Notepad &rarr;
                </a>
            </div>

            <div class="benefit-box">
                <h3>Why choose MyPad as your online notepad?</h3>
                <p>
                    Unlike traditional online pastebins or bulky note-taking platforms, MyPad doesn't force you through multi-step account creation or clutter your screen with ads. You pick a URL, and that URL becomes your permanent, editable workspace. Everything is preserved, autosaved, and accessible from any browser on the planet.
                </p>
            </div>
        </section>
    </main>

    <%@ include file="includes/footer.jsp" %>

</body>
</html>
